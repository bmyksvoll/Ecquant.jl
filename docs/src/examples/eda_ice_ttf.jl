
using DataFrames
using XLSX
using Dates
using TimeSeries

# Define the path to the Excel file
file_path = joinpath(@__DIR__, "..", "data", "ICE_TTF_FUT.xlsx")

# Read the Excel file into a DataFrame
df = DataFrame(XLSX.readtable(file_path, "Sheet1", infer_eltypes=true))
df
# Rename the Index column to Date and convert to Date format
DataFrames.rename!(df, :Index => :Date)



ts = TimeArray(df, timestamp=:Date)

stack(ts, Not(:Date), variable_name=:Month, value_name=:Value)

lr = TimeSeries.percentchange(ts, :log)

moving(mean, lr, 30)

plot(ts, layout=2, title="ICE TTF Futures Prices", legend=false)


# Pivot the DataFrame to longer format
df_long = stack(df, Not(:Index), variable_name=:Month, value_name=:Value)

# Extract the month number from the Month column
df_long.Month = parse.(Int, replace.(df_long.Month, r"[^0-9]" => ""))

# Sort the DataFrame by Index and Month
sort!(df_long, [:Index, :Month])

# Calculate log returns
df_long[:, :LogReturn] = [NaN; diff(log.(df_long.Value))]


# Group by Month and calculate log returns for each group
df_long = combine(groupby(df_long, :Month), :Index, :Value, :LogReturn => (x -> [NaN; diff(log.(x))]) => :LogReturn)