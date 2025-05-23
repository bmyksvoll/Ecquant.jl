struct BSRVolatilityModel
    a::Float64
    b::Float64
    c::Float64

    BSRVolatilityModel(a=0.9, b=0.6, c=0.1) = new(a, b, c)
end


function spence(z::Float64)
    return reli2(1-z)
end

function σ(model::BSRVolatilityModel, t::Float64, T::Float64)
    """Instantaneous volatility function"""
     @assert T >= t "T must be greater than or equal to t"
    return model.a / (T - t + model.b) + model.c
end

function σ(model::BSRVolatilityModel, t::Float64, tau::Float64, T::Float64)
    """Bjerksund Stensland Rasmussen point volatility"""
    function variance_integral(model::BSRVolatilityModel, s::Float64, T::Float64)
        """Equation (7) in BS 2010"""
         @assert T >= s "T must be greater than or equal to s"
        variance = (model.a^2 / (T - s + model.b) -
                    2 * model.a * model.c * log(T - s + model.b) +
                    model.c^2 * s)
        return variance
    end

    upper = variance_integral(model, tau, T)
    lower = variance_integral(model, t, T)
    var = (upper - lower) / (tau - t)
    return sqrt(var)
end

function σ(model::BSRVolatilityModel, t::Float64, tau::Float64, T1::Float64, T2::Float64)
    """
    Bjerksund Stensland Rasmussen plug-in volatility
    applied for flow delivery
    """
    X(s) = model.b + 0.5 * (T2 + T1) - s
    alpha = 0.5 * (T2 - T1)

    integral1(x) = begin
        (x + alpha) * log(x + alpha)^2 -
        2 * (x + alpha) * log(x + alpha) * log(x - alpha) +
        4 * alpha * log(2 * alpha) * log((x - alpha) / (2 * alpha)) -
        4 * alpha * spence((x + alpha) / (2 * alpha)) +
        (x - alpha) * log(x - alpha)^2
    end

    integral2(x) = begin
        (x + alpha) * log(x + alpha) - (x - alpha) * log(x - alpha)
    end

    xu = X(t)
    xl = X(tau)

    variance = (
        (model.a / (T2 - T1))^2 * (integral1(xu) - integral1(xl)) +
        (2 * model.a * model.c) / (T2 - T1) * (integral2(xu) - integral2(xl)) +
        model.c^2 * (tau - t)
    )
    return sqrt(variance / (tau - t))
end



function σ₁(model::BSRVolatilityModel, t::Float64, tau::Float64, T::Float64)
    """First factor volatility"""
    upper = first_factor_integral(model, tau, T)
    lower = first_factor_integral(model, t, T)
    variance = (upper - lower) / (tau - t)
    return sqrt(variance)
end

function σ₂(model::BSRVolatilityModel, t::Float64, tau::Float64, T::Float64)
    """Second factor volatility"""
    upper = second_factor_integral(model, tau, T)
    lower = second_factor_integral(model, t, T)
    variance = (upper - lower) / (tau - t)
    return sqrt(variance)
end

function σ₃(model::BSRVolatilityModel, T)
    """Third factor volatility"""
    return model.c
end

function first_factor_integral(model::BSRVolatilityModel, s::Float64, T::Float64)
    """First volatility factor function"""
    return model.a^2 / (T - s + model.b)
end

function second_factor_integral(model::BSRVolatilityModel, s::Float64, T::Float64)
    """Second volatility factor integral function"""
    return -2 * model.a * model.c * log(T - s + model.b)
end


function calibrate_sigma(sigma_0, sigma_mid, sigma_inf, t_mid)
    # Calculate c directly from the value of sigma at infinity
    c = sigma_inf

    # Calculate b using the derived formula
    b = (sigma_mid - sigma_inf) * t_mid / (sigma_0 - sigma_mid)

    # Calculate a using the derived formula
    a = b * (sigma_0 - sigma_inf)

    return a, b, c
end