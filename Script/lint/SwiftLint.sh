#!/bin/sh

# 사용: /bin/sh Script/lint/SwiftLint.sh <SRCROOT> [CONFIG]
# CONFIG 생략 시 ${SRCROOT}/.swiftlint.yml 사용
# 워닝 메시지는 설정 파일의 규칙 주석(한글)으로 치환한다.

SRCROOT=$1
CONFIG="${2:-${SRCROOT}/.swiftlint.yml}"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AWK_SCRIPT="${SCRIPT_DIR}/swiftlint_korean.awk"

# Xcode Run Script PATH에는 Homebrew 경로가 없을 수 있음 (특히 Apple Silicon)
export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"

if [ -x /opt/homebrew/bin/swiftlint ]; then
    SWIFTLINT=/opt/homebrew/bin/swiftlint
elif [ -x /usr/local/bin/swiftlint ]; then
    SWIFTLINT=/usr/local/bin/swiftlint
else
    SWIFTLINT=$(command -v swiftlint 2>/dev/null)
fi

if [ -z "${SWIFTLINT}" ] || [ ! -x "${SWIFTLINT}" ]; then
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    exit 0
fi

if [ ! -f "${CONFIG}" ]; then
    echo "warning: SwiftLint config not found: ${CONFIG}"
    exit 0
fi

cd "${SRCROOT}" || exit 0

if [ -f "${AWK_SCRIPT}" ]; then
    "${SWIFTLINT}" --lenient --config "${CONFIG}" | awk -v cfg="${CONFIG}" -f "${AWK_SCRIPT}"
else
    echo "warning: swiftlint_korean.awk not found: ${AWK_SCRIPT}"
    "${SWIFTLINT}" --lenient --config "${CONFIG}"
fi
