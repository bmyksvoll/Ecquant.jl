using PolyLog:reli2

struct BSRModel
    a::Float64
    b::Float64
    c::Float64

    BSRModel(a=0.9, b=0.6, c=0.1) = new(a, b, c)
end


function spence(z::Float64)
    return reli2(1-z)
end

function sigma_instant(model::BSRModel, t::Float64, T::Float64)
    """Instantaneous volatility function"""
    return model.a / (T - t + model.b) + model.c
end

function sigma(model::BSRModel, t::Float64, tau::Float64, T::Float64)
    """Bjerksund Stensland Rasmussen point volatility"""
    upper = variance_integral(model, tau, T)
    lower = variance_integral(model, t, T)
    var = (upper - lower) / (tau - t)
    return sqrt(var)
end

function sigma_plugin(model::BSRModel, t::Float64, tau::Float64, T1::Float64, T2::Float64)
    """
    Bjerksund Stensland Rasmussen plug-in volatility
    applied for flow delivery
    """
    X(s) = model.b + 0.5 * (T2 + T1) - s

    integral1(x) = begin
        alpha = 0.5 * (T2 - T1)
        (x + alpha) * log(x + alpha)^2 -
        2 * (x + alpha) * log(x + alpha) * log(x - alpha) +
        4 * alpha * log(2 * alpha) * log((x - alpha) / (2 * alpha)) -
        4 * alpha * spence((x + alpha) / (2 * alpha)) +
        (x - alpha) * log(x - alpha)^2
    end

    integral2(x) = begin
        alpha = 0.5 * (T2 - T1)
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

function variance_integral(model::BSRModel, s::Float64, T::Float64)
    """Equation (7) in BS 2010"""
    variance = (model.a^2 / (T - s + model.b) -
                2 * model.a * model.c * log(T - s + model.b) +
                model.c^2 * s)
    return variance
end

function sigma_factor1(model::BSRModel, t::Float64, tau::Float64, T::Float64)
    """First factor volatility"""
    upper = first_factor_integral(model, tau, T)
    lower = first_factor_integral(model, t, T)
    variance = (upper - lower) / (tau - t)
    return sqrt(variance)
end

function sigma_factor2(model::BSRModel, t::Float64, tau::Float64, T::Float64)
    """Second factor volatility"""
    upper = second_factor_integral(model, tau, T)
    lower = second_factor_integral(model, t, T)
    variance = (upper - lower) / (tau - t)
    return sqrt(variance)
end

function sigma_factor3(model::BSRModel, T)
    """Third factor volatility"""
    return model.c
end

function first_factor_integral(model::BSRModel, s::Float64, T::Float64)
    """First volatility factor function"""
    return model.a^2 / (T - s + model.b)
end

function second_factor_integral(model::BSRModel, s::Float64, T::Float64)
    """Second volatility factor integral function"""
    return -2 * model.a * model.c * log(T - s + model.b)
end

