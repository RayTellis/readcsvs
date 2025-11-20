# readcsvs

A single function R package that reads and combines multiple CSV files into a single data frame using DuckDB's efficient parallel processing.

## Overview

`readcsvs::read_csvs()` uses DuckDB to quickly read and union multiple CSV files matching a pattern, automatically adding a filename column to track the source of each row. It normalizes column names and handles various CSV formats.

## Installation

```r
# Install devtools if needed
install.packages("devtools")

# Install package from GitHub
devtools::install_github("RayTellis/readcsvs")
```

## Usage
```r
read_csvs(
  pattern = "*",
  quote = "\"",
  delim = ",",
  skip = 0,
  header = TRUE
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pattern` | character | `"*"` | File pattern to match (without `.csv` extension). Supports wildcards. |
| `quote` | character | `"\""` | Character used to quote fields in the CSV files. |
| `delim` | character | `","` | Field delimiter character. |
| `skip` | integer | `0` | Number of lines to skip at the beginning of each file. |
| `header` | logical | `TRUE` | Whether the first row contains column names. |



## Features

- **Efficient parallel processing**: Uses DuckDB's optimized CSV reader
- **Automatic file combining**: Unions multiple CSVs with `union_by_name = true`
- **Filename tracking**: Adds a `filename` column showing the source file (without path or extension)
- **Column normalization**: Automatically normalizes column names across files
- **Flexible matching**: Supports wildcard patterns to select specific files
- **Clean resource management**: Automatically disconnects from DuckDB on exit

## Examples

### Read all CSV files in the current directory
```r
data <- read_csvs()
```

### Read files matching a specific pattern
```r
# Read all files starting with "sales_"
sales_data <- read_csvs(pattern = "sales_*")

# Read a single file
customer_data <- read_csvs(pattern = "customers_2024")
```

### Handle different CSV formats
```r
# Tab-delimited files
tsv_data <- read_csvs(pattern = "data_*", delim = "\t")

# Files with single quotes
quoted_data <- read_csvs(pattern = "export_*", quote = "'")

# Skip header rows
no_header_data <- read_csvs(pattern = "raw_*", skip = 2, header = FALSE)
```

## Output

Returns a data frame with:
- A `filename` column containing the source file name (without path or `.csv` extension)
- All columns from the matched CSV files
- Rows from all files combined

## Notes

- The `.csv` extension is automatically added to the pattern, so you don't need to include it
- Column names are normalized across all files for consistent merging
- Files are matched relative to the current working directory
