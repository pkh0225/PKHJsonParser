# SwiftLint 경고 메시지를 .swiftlint.yml 규칙 주석(한글)으로 치환한다.
# -v cfg="/path/to/.swiftlint.yml" 로 설정 파일을 넘긴다.
# Xcode가 파싱하는 "파일:줄:칸: warning|error:" 형식은 그대로 유지한다.
BEGIN {
    if (cfg == "") {
        print "warning: swiftlint_korean.awk requires -v cfg=/.swiftlint.yml" > "/dev/stderr"
        exit 1
    }
    while ((getline line < cfg) > 0) {
        # "  - rule_name # 설명" 형태만 매핑 (주석 처리된 규칙은 제외)
        if (line ~ /^[ \t]*-[ \t]+[a-z0-9_]+[ \t]+#/) {
            sub(/^[ \t]*-[ \t]+/, "", line)
            id = line
            sub(/[ \t]+#.*$/, "", id)
            comment = line
            sub(/^[^#]*#[ \t]*/, "", comment)
            if (id != "" && comment != "") {
                m[id] = comment
            }
        }
    }
    close(cfg)
}
{
    if (match($0, /\([a-z0-9_]+\)$/)) {
        id = substr($0, RSTART + 1, RLENGTH - 2)
        if (id in m) {
            p = index($0, ": warning: ")
            sev = "warning"
            if (p == 0) {
                p = index($0, ": error: ")
                sev = "error"
            }
            if (p > 0) {
                print substr($0, 1, p - 1) ": " sev ": " m[id] " (" id ")"
                next
            }
        }
    }
    print
}
