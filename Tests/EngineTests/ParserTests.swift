import Testing

@testable import Regex

@Test(arguments: [
    ([AST.Char("a")], PSQ.Plus, [AST.Plus(.Char("a"))]),
    ([.Char("a"), .Char("b")], .Star, [.Char("a"), .Star(.Char("b"))]),
])
func testParsePlusStarQuestion(seq: [AST], astType: PSQ, expected: [AST]) async throws {
    var seq = seq
    try! parsePlusStarQuestion(seq: &seq, astType: astType)
    #expect(seq == expected)
}

@Test(arguments: [
    ([AST.Char("a")], AST.Char("a")),
    ([.Char("a"), .Char("b")], .Or(.Char("a"), .Char("b"))),
    ([.Char("a"), .Char("b"), .Char("c")], .Or(.Char("a"), .Or(.Char("b"), .Char("c")))),
    ([.Char("a"), .Char("b"), .Char("c"), .Char("d")], .Or(.Char("a"), .Or(.Char("b"), .Or(.Char("c"), .Char("d"))))),
])
func testFoldOr(seq: [AST], expected: AST) async throws {
    var seq = seq
    let result = try! foldOr(&seq)
    #expect(result == expected)
}

@Test(arguments: [
    ("a", AST.Seq([.Char("a")])),
    ("b", .Seq([.Char("b")])),
    ("ab", .Seq([.Char("a"), .Char("b")])),
    ("a+", .Seq([.Plus(.Char("a"))])),
    ("ab+", .Seq([.Char("a"), .Plus(.Char("b"))])),
    ("ab*", .Seq([.Char("a"), .Star(.Char("b"))])),
    ("ab?", .Seq([.Char("a"), .Question(.Char("b"))])),
    ("a|b", .Or(.Seq([.Char("a")]), .Seq([.Char("b")]))),
    ("a|b|c", .Or(.Seq([.Char("a")]), .Or(.Seq([.Char("b")]), .Seq([.Char("c")])))),
    ("(a)", .Seq([.Seq([.Char("a")])])),
    ("(a)(b)", .Seq([.Seq([.Char("a")]), .Seq([.Char("b")])])),
    ("(ab)", .Seq([.Seq([.Char("a"), .Char("b")])])),
    ("(ab)+", .Seq([.Plus(.Seq([.Char("a"), .Char("b")]))])),
    ("(ab)*", .Seq([.Star(.Seq([.Char("a"), .Char("b")]))])),
    ("(ab)?", .Seq([.Question(.Seq([.Char("a"), .Char("b")]))])),
    ("((a))", .Seq([.Seq([.Seq([.Char("a")])])])),
    ("(a|b)", .Seq([.Or(.Seq([.Char("a")]), .Seq([.Char("b")]))])),
    ("(ab|cde)*", .Seq([.Star(.Or(.Seq([.Char("a"), .Char("b")]), .Seq([.Char("c"), .Char("d"), .Char("e")])))])),
    ("((a)b)", .Seq([.Seq([.Seq([.Char("a")]), .Char("b")])])),
    ("(ab)+c", .Seq([.Plus(.Seq([.Char("a"), .Char("b")])), .Char("c")])),
    ("\\*", .Seq([.Char("*")])),
    ("\\\\", .Seq([.Char("\\")])),
    ("\\a", .Seq([.Char("a")])),
    ("ab(cd)?", .Seq([.Char("a"), .Char("b"), .Question(.Seq([.Char("c"), .Char("d")]))])),
    ("a(bc|e+)*", .Seq([.Char("a"), .Star(.Or(.Seq([.Char("b"), .Char("c")]), .Seq([.Plus(.Char("e"))])))])),
])
func testParse(input: String, expected: AST) async throws {
    let result = try! parse(expr: input)
    #expect(result == expected)
}

@Test(arguments: [
    ("+a", ParseError.InvalidQuantifier),
    ("*", .InvalidQuantifier),
    ("(?)", .InvalidQuantifier),
    ("(a", .NoRightParen),
    ("((a)", .NoRightParen),
    ("a)", .InvalidCharacter(")")),
    ("|a", .InvalidCharacter("|")),
    ("", .Empty),
    ("()", .Empty),
    ("\\", .Empty),
])
func testParseError(input: String, expected: ParseError) async throws {
    #expect(throws: expected) {
        _ = try parse(expr: input)
    }
}
