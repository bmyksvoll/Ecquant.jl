using DataFrames
using Dates
using Ecquant

instruments = DataFrame([
    (isActive = true, name = "W21-13", start_date = DateTime(2013, 5, 20), end_date = DateTime(2013, 5, 26), price = 33.65),
    (isActive = true, name = "W22-13", start_date = DateTime(2013, 5, 27), end_date = DateTime(2013, 6, 2), price = 35.77),
    (isActive = true, name = "W23-13", start_date = DateTime(2013, 6, 3), end_date = DateTime(2013, 6, 9), price = 36.58),
    (isActive = true, name = "W24-13", start_date = DateTime(2013, 6, 10), end_date = DateTime(2013, 6, 16), price = 35.93),
    (isActive = true, name = "W25-13", start_date = DateTime(2013, 6, 17), end_date = DateTime(2013, 6, 23), price = 33.14),
    (isActive = true, name = "W26-13", start_date = DateTime(2013, 6, 24), end_date = DateTime(2013, 6, 30), price = 34.16),
    (isActive = false, name = "MJUN-13", start_date = DateTime(2013, 6, 1), end_date = DateTime(2013, 6, 30), price = 35.35),
    (isActive = true, name = "MJUL-13", start_date = DateTime(2013, 7, 1), end_date = DateTime(2013, 7, 31), price = 33.14),
    (isActive = true, name = "MAUG-13", start_date = DateTime(2013, 8, 1), end_date = DateTime(2013, 8, 31), price = 35.72),
    (isActive = true, name = "MSEP-13", start_date = DateTime(2013, 9, 1), end_date = DateTime(2013, 9, 30), price = 38.41),
    (isActive = true, name = "MOCT-13", start_date = DateTime(2013, 10, 1), end_date = DateTime(2013, 10, 31), price = 38.81),
    (isActive = true, name = "MNOV-13", start_date = DateTime(2013, 11, 1), end_date = DateTime(2013, 11, 30), price = 40.94),
    (isActive = false, name = "Q3-13", start_date = DateTime(2013, 7, 1), end_date = DateTime(2013, 9, 30), price = 35.72),
    (isActive = true, name = "Q4-13", start_date = DateTime(2013, 10, 1), end_date = DateTime(2013, 12, 31), price = 40.53),
    (isActive = true, name = "Q1-14", start_date = DateTime(2014, 1, 1), end_date = DateTime(2014, 3, 31), price = 42.40),
    (isActive = true, name = "Q2-14", start_date = DateTime(2014, 4, 1), end_date = DateTime(2014, 6, 30), price = 33.39),
    (isActive = true, name = "Q3-14", start_date = DateTime(2014, 7, 1), end_date = DateTime(2014, 9, 30), price = 31.78),
    (isActive = true, name = "Q4-14", start_date = DateTime(2014, 10, 1), end_date = DateTime(2014, 12, 31), price = 38.25),
    (isActive = true, name = "Q1-15", start_date = DateTime(2015, 1, 1), end_date = DateTime(2015, 3, 31), price = 40.73),
    (isActive = true, name = "Q2-15", start_date = DateTime(2015, 4, 1), end_date = DateTime(2015, 6, 30), price = 32.64),
    (isActive = true, name = "Q3-15", start_date = DateTime(2015, 7, 1), end_date = DateTime(2015, 9, 30), price = 30.87),
    (isActive = true, name = "Q4-15", start_date = DateTime(2015, 10, 1), end_date = DateTime(2015, 12, 31), price = 37.22),
    (isActive = false, name = "CAL-14", start_date = DateTime(2014, 1, 1), end_date = DateTime(2014, 12, 31), price = 36.43),
    (isActive = false, name = "CAL-15", start_date = DateTime(2015, 1, 1), end_date = DateTime(2015, 12, 31), price = 35.12),
    (isActive = true, name = "CAL-16", start_date = DateTime(2016, 1, 1), end_date = DateTime(2016, 12, 31), price = 34.10),
    (isActive = false, name = "CAL-17", start_date = DateTime(2017, 1, 1), end_date = DateTime(2017, 12, 31), price = 35.22),
    (isActive = false, name = "CAL-18", start_date = DateTime(2018, 1, 1), end_date = DateTime(2018, 12, 31), price = 36.36),
    (isActive = false, name = "CAL-19", start_date = DateTime(2019, 1, 1), end_date = DateTime(2019, 12, 31), price = 37.44),
    (isActive = false, name = "CAL-20", start_date = DateTime(2020, 1, 1), end_date = DateTime(2020, 12, 31), price = 38.58),
    (isActive = false, name = "CAL-21", start_date = DateTime(2021, 1, 1), end_date = DateTime(2021, 12, 31), price = 39.73),
    (isActive = false, name = "CAL-22", start_date = DateTime(2022, 1, 1), end_date = DateTime(2022, 12, 31), price = 40.93),
    (isActive = false, name = "CAL-23", start_date = DateTime(2023, 1, 1), end_date = DateTime(2023, 12, 31), price = 42.15),
])

trade_date = DateTime(2013, 5, 13)

# Filter only active instruments
active_instruments = filter(row -> row.isActive, instruments)

# Create an instance of ForwardCurve
etrm_fc = ForwardCurve("EUR", "MWh", trade_date, active_instruments)

# Plot the forward curve
plot_curve(etrm_fc)



instruments.calc_price = price.(Ref(etrm_fc.spline), etrm_fc.instruments.start_time, etrm_fc.instruments.end_time)

# Test No-Arbitrage condition: the calculated price should be equal to the market price
@test all(isapprox.(instruments.price, instruments.calc_price, atol=1e-10))