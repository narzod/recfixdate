function normalize_date(date_parts, format_spec) {
    command = "date -d \"" date_parts "\" +\"" format_spec "\" 2>&1"
    command | getline result
    close(command)
    return (result ~ /invalid/) ? "" : result
}

function after_colon() {
    result = substr($0, index($0, ":") + 2)
    gsub(/[ \t]+$/, "", result)
    return result
}

BEGIN {
    default_format = ENVIRON["RECFIXDATE_FORMAT"]
}

$1 == "%rec:" {
    record_type = $2
    format_spec = default_format
    delete date_field_names
    num_date_fields = 0
}

record_type != "" && $1 == "%type:" && $3 == "date" {
    date_field_names[++num_date_fields] = $2
    print
    next
}

record_type != "" && $1 == "%dateTypeFormat:" {
    format_spec = after_colon()
    print
    next
}

{
    matched = 0
    if ($2 != "") {
        for (i = 1; i <= num_date_fields; i++) {
            if ($1 == (date_field_names[i] ":")) {
                date_parts = after_colon()
                normalized_date = normalize_date(date_parts, format_spec)

                if (normalized_date == "") {
                    errors[NR] = date_parts
                }

                print $1, (normalized_date == "" ? date_parts : normalized_date)
                matched = 1
                break
            }
        }
    }
    if (!matched) { print }
}

END {
    if (length(errors) > 0) {
        print "---\nThe following dates could not be normalized:" > "/dev/stderr"
        for (line_num in errors) {
            printf("- at line %d: '%s'\n", line_num, errors[line_num]) > "/dev/stderr"
        }
    }
}
