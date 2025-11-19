#' Read and Combine Multiple CSV Files
#'
#' Uses DuckDB to efficiently read and union multiple CSV files matching a pattern.
#' Automatically adds a filename column to track the source of each row.
#'
#' @param pattern Character string specifying file pattern to match (without .csv extension).
#'   Supports wildcards. Default is "*" to match all CSV files.
#' @param quote Character used to quote fields in the CSV files. Default is "\"".
#' @param delim Field delimiter character. Default is ",".
#' @param skip Integer number of lines to skip at the beginning of each file. Default is 0.
#' @param header Logical indicating whether the first row contains column names. Default is TRUE.
#'
#' @return A data frame with a 'filename' column (source file without path/extension)
#'   plus all columns from the matched CSV files.
#'
#' @examples
#' \dontrun{
#' # Read all CSV files
#' data <- read_csvs()
#'
#' # Read files matching a pattern
#' sales <- read_csvs(pattern = "sales_*")
#'
#' # Handle tab-delimited files
#' tsv_data <- read_csvs(pattern = "data_*", delim = "\t")
#' }
#'
#' @export
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
#' @importFrom duckdb duckdb
read_csvs <- function(pattern = "*", quote = "\"", delim = ",", skip = 0, header = TRUE) {
    pattern <- sub("\\.csv$", "", (pattern))
    pattern <- sub("\\.CSV$", "", (pattern))
    delim <- gsub("'", "''", delim)
    multi_read <- DBI::dbConnect(duckdb::duckdb())
    on.exit(DBI::dbDisconnect(multi_read))
    x <- DBI::dbGetQuery(
        multi_read,
        paste0("
         select
                -- Get just the file name (splits by / and takes the last part)
                replace(list_last(str_split(replace(filename, '\\', '/'), '/')), '.csv', '') as filename,
                * exclude(filename),
            from read_csv(
            '", pattern, ".csv',
                filename = true,
                union_by_name = true,
                quote = '", quote, "',
                delim = '", delim, "',
                skip = ", skip, ",
                header = ", header, ",
                normalize_names = true
            )
        ")
    )
    return(x)
}
