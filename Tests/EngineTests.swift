import Testing

@testable import Regex

struct TestCase {
    let expr: String
    let target: String
    let expected: Bool
}

@Test(arguments: [
    (expr: "a", target: "a", expected: true),
    (expr: "a", target: "ax", expected: true),
    (expr: "a", target: "xa", expected: true),
    (expr: "a", target: "", expected: false),
    (expr: "a", target: "x", expected: false),

    (expr: "ab", target: "ab", expected: true),
    (expr: "ab", target: "aba", expected: true),
    (expr: "ab", target: "xaabbb", expected: true),
    (expr: "ab", target: "ba", expected: false),

    (expr: "a+", target: "a", expected: true),
    (expr: "a+", target: "aa", expected: true),
    (expr: "a+", target: "ab", expected: true),
    (expr: "a+", target: "ba", expected: true),
    (expr: "a+", target: "aaab", expected: true),
    (expr: "a+", target: "b", expected: false),

    (expr: "ab+", target: "ab", expected: true),
    (expr: "ab+", target: "aaab", expected: true),
    (expr: "ab+", target: "abbb", expected: true),

    (expr: "(ab)+", target: "ab", expected: true),
    (expr: "(ab)+", target: "abab", expected: true),
    (expr: "(ab)+", target: "", expected: false),
    (expr: "(ab)+", target: "ba", expected: false),
    (expr: "(ab)+", target: "axb", expected: false),

    (expr: "(ab)*", target: "", expected: true),
    (expr: "(ab)*", target: "ab", expected: true),
    (expr: "(ab)*", target: "aba", expected: true),
    (expr: "(ab)*", target: "abab", expected: true),

    (expr: "(ab)?", target: "", expected: true),
    (expr: "(ab)?", target: "ab", expected: true),
    (expr: "(ab)?", target: "aba", expected: true),

    (expr: "(ab|cd)", target: "ab", expected: true),
    (expr: "(ab|cd)", target: "cd", expected: true),
    (expr: "(ab|cd)", target: "xab", expected: true),
    (expr: "(ab|cd)", target: "abx", expected: true),
    (expr: "(ab|cd)", target: "xcd", expected: true),
    (expr: "(ab|cd)", target: "cdx", expected: true),
    (expr: "(ab|cd)", target: "ac", expected: false),
    (expr: "(ab|cd)", target: "bc", expected: false),
    (expr: "(ab|cd)", target: "bd", expected: false),

    (expr: "a\\*", target: "a*", expected: true),
    (expr: "a\\*", target: "", expected: false),
    (expr: "a\\*", target: "a", expected: false),
    (expr: "a\\*", target: "a+", expected: false),

    (expr: "a\\+", target: "a+", expected: true),
    (expr: "a\\+", target: "a", expected: false),
    (expr: "a\\+", target: "aa", expected: false),
    (expr: "a\\+", target: "a*", expected: false),

    (expr: "a(bc|e+)*", target: "a", expected: true),
    (expr: "a(bc|e+)*", target: "abc", expected: true),
    (expr: "a(bc|e+)*", target: "abcbc", expected: true),
    (expr: "a(bc|e+)*", target: "ae", expected: true),
    (expr: "a(bc|e+)*", target: "aee", expected: true),
    (expr: "a(bc|e+)*", target: "abce", expected: true),
    (expr: "a(bc|e+)*", target: "aabce", expected: true),
    (expr: "a(bc|e+)*", target: "aeebcebce", expected: true),
    (expr: "a(bc|e+)*", target: "xxxxxxxxaeebcebcehxxxxxx", expected: true),

    (expr: "a(bc|e+)*", target: "bc", expected: false),
    (expr: "a(bc|e+)*", target: "e", expected: false),
    (expr: "a(bc|e+)*", target: "bce", expected: false),
    (expr: "a(bc|e+)*", target: "x", expected: false),
    (expr: "a(bc|e+)*", target: "xe", expected: false),
])
func testMatchSuccess(expr: String, target: String, expected: Bool) async throws {
    let actual = try match(expr: expr, target: target)
    #expect(actual == expected)
}
