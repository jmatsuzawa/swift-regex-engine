import Testing

@testable import Regex

@Test(arguments: [
    // a
    (AST.Seq([.Char("a")]), [
        Instruction.Char("a"),
        .Match,
    ]),
    // ab
    (.Seq([.Char("a"), .Char("b")]), [
        .Char("a"),
        .Char("b"),
        .Match,
    ]),
    // a|b
    (.Or(.Seq([.Char("a")]), .Seq([.Char("b")])), [
        .Split(1, 3),   // 0
        .Char("a"),     // 1
        .Jump(4),       // 2
        .Char("b"),     // 3
        .Match,         // 4
    ]),
    // a|b|c
    (.Or(.Seq([.Char("a")]), .Or(.Seq([.Char("b")]), .Seq([.Char("c")]))), [
        .Split(1, 3),   // 0
        .Char("a"),     // 1
        .Jump(7),       // 2
        .Split(4, 6),   // 3
        .Char("b"),     // 4
        .Jump(7),       // 5
        .Char("c"),     // 6
        .Match,         // 7
    ]),
    (.Seq([.Char("a"), .Question(.Char("b"))]), [
        .Char("a"),     // 0
        .Split(2, 3),   // 1
        .Char("b"),     // 2
        .Match,         // 3
    ]),
    // ab(cd)?
    (.Seq([.Char("a"), .Char("b"), .Question(.Seq([.Char("c"), .Char("d")]))]), [
        .Char("a"),     // 0
        .Char("b"),     // 1
        .Split(3, 5),   // 2
        .Char("c"),     // 3
        .Char("d"),     // 4
        .Match,         // 5
    ]),
    // ab*
    (.Seq([.Char("a"), .Star(.Char("b"))]), [
        .Char("a"),     // 0
        .Split(2, 4),   // 1
        .Char("b"),     // 2
        .Jump(1),       // 3
        .Match,         // 4
    ]),
    // a+
    (.Seq([.Plus(.Char("a"))]), [
        .Char("a"),     // 0
        .Split(0, 2),   // 1
        .Match,         // 2
    ]),
    // a(bc|e+)*
    (.Seq([ .Char("a"), .Star( .Or( .Seq([ .Char("b"), .Char("c") ]), .Seq([ .Plus( .Char("e")) ]))) ]), [
        .Char("a"),     // 0
        .Split(2, 9),   // 1
        .Split(3, 6),   // 2
        .Char("b"),     // 3
        .Char("c"),     // 4
        .Jump(8),       // 5
        .Char("e"),     // 6
        .Split(6, 8),   // 7
        .Jump(1),       // 8
        .Match,         // 9
    ]),
])
func testGenerateCode(input: AST, expectedInstruction: [Instruction]) async throws {
    var sut = Generator()
    #expect(try sut.generateCode(ast: input) == expectedInstruction)
}
