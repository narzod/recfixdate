# recfixdate

A utility to ensure consistent date representations in GNU recutils databases.

## Overview

recfixdate standardizes date expressions in recutils recfiles by transforming them into a consistent format. It processes date fields based on their type declarations and uses GNU date for both interpreting input dates and formatting output dates.

## Usage

```bash
recfixdate [OPTION]... [FILE]
```

### Options

- `-h, --help`     Show help and exit
- `-v, --version`  Display version info and exit
- `-i, --in-place` Edit files in place

If no `FILE` is specified, reads from standard input and outputs to standard output.

### File Format Requirements

- `%rec` descriptor must appear before type declarations and format specifications
- Declare date fields with `%type: field_name date`
- Specify formats with `%dateTypeFormat: format_string`

### Environment Variables

- `RECFIXDATE_FORMAT`: Sets global date output format
- `LC_TIME`: Controls default date representation if no format is specified

## Date Handling

### Input Date Processing

`recfixdate` leverages GNU date's flexible parsing to support multiple date and time input formats:

| Type              | Examples                                               |
|-------------------|--------------------------------------------------------|
| Natural Language  | "yesterday", "next Monday", "today", "last Friday"     |
| Relative Times    | "2 hours ago", "last week", "next month"               |
| Standard Formats  | "Dec 1, 2023 3:15pm", "2023-12-25", "01/15/2024"       |
| ISO 8601          | "2023-12-14T15:00:00", "20231214"                      |
| Time of Day       | "3pm", "15:00", "noon", "midnight"                     |

### Output Format Precedence

The program determines the output date format through the following precedence:

1. Per-record format using %dateTypeFormat descriptors in the input file
2. Global format from the RECFIXDATE_FORMAT environment variable
3. System default format based on LC_TIME locale settings

Format strings use GNU date specifiers, such as:

| Specifier | Description           | Example |
|-----------|-----------------------|---------|
| %Y        | Year                  | 2023    |
| %m        | Month (01-12)         | 12      |
| %d        | Day (01-31)           | 25      |
| %H        | Hour (00-23)          | 15      |
| %I        | Hour (01-12)          | 03      |
| %M        | Minute                | 15      |
| %p        | AM/PM                 | PM      |

Common format combinations:

| Format String      | Output          | Description              |
|--------------------|-----------------|--------------------------|
| `%Y-%m-%d`         | 2023-12-25      | ISO 8601 date           |
| `%Y-%m-%d %H:%M`   | 2023-12-25 15:30| ISO 8601 date + time    |
| `%b %d, %Y`        | Dec 25, 2023    | US style                |
| `%d/%m/%Y`         | 25/12/2023      | European style          |

For a full list, refer to the [GNU date documentation](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html).

## Examples

### Basic Usage

To process a single file:
```bash
recfixdate timesheet.rec > normalized.rec
```

Edit multiple files in place:
```bash
recfixdate -i *.rec
```

Using standard input/output:
```bash
cat timesheet.rec | recfixdate > normalized.rec
```

### Sample Transformation

**Input (`timesheet.rec`):**
```rec
%rec: TimeEntry
%type: start_time date
%type: end_time date
%dateTypeFormat: %Y-%m-%d %H:%M

start_time: yesterday 3pm
end_time: Dec 1, 2023 3:15pm
```

**Output (`normalized.rec`):**
```rec
%rec: TimeEntry
%type: start_time date
%type: end_time date
%dateTypeFormat: %Y-%m-%d %H:%M

start_time: 2023-12-14 15:00
end_time: 2023-12-01 15:15
```

## Requirements

- GNU coreutils (specifically for the `date` command)
- `awk`

## Error Handling

Reports:

- Invalid/unreadable input files
- Permission errors with `-i`
- Invalid dates (with line numbers)
- Missing dependencies

## Limitations

- Invalid dates remain unchanged
- Requires write permissions with `-i`
- Creates temporary files for `-i` in the input file’s directory

## License

&copy; 2023 Jeff Singer.  
Licensed under GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.  
This is free software: you are free to change and redistribute it with NO WARRANTY.

## See Also

- [GNU recutils documentation](https://www.gnu.org/software/recutils/)
- [GNU date documentation](https://www.gnu.org/software/coreutils/manual/html_node/date-invocation.html)
