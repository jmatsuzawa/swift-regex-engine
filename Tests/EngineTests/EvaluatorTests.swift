import Testing

@testable import Regex

@Test(arguments: [
    ([Instruction.Char("a"), .Match], "a"),
    ([.Char("a"), .Match], "ax"),
    ([.Char("a"), .Match], "xa"),
    ([.Char("a"), .Match], "xax"),
    ([.Char("a"), .Char("b"), .Match], "ab"),
    ([.Char("a"), .Char("b"), .Match], "xab"),
    ([.Char("a"), .Char("b"), .Match], "abx"),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], "a"),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], "b"),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], "xa"),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], "bx"),
    ([.Split(1, 3), .Char("a"), .Jump(7), .Split(4, 6), .Char("b"), .Jump(7), .Char("c"), .Match], "a"),
    ([.Split(1, 3), .Char("a"), .Jump(7), .Split(4, 6), .Char("b"), .Jump(7), .Char("c"), .Match], "b"),
    ([.Split(1, 3), .Char("a"), .Jump(7), .Split(4, 6), .Char("b"), .Jump(7), .Char("c"), .Match], "c"),
    ([.Split(1, 2), .Char("a"), .Match], ""),
    ([.Split(1, 2), .Char("a"), .Match], "a"),
    ([.Split(1, 2), .Char("a"), .Match], "x"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "a"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "abc"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "abcbc"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "ae"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "aee"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "abce"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "aebc"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "aeebcebce"),
])
func testEvalSuccess(instructions: [Instruction], target: String) async throws {
    try #expect(eval(instructions: instructions, target: target) == true)
}

@Test(arguments: [
    ([Instruction.Char("a"), .Match], ""),
    ([Instruction.Char("a"), .Match], "b"),
    ([.Char("a"), .Char("b"), .Match], "a"),
    ([.Char("a"), .Char("b"), .Match], "b"),
    ([.Char("a"), .Char("b"), .Match], "ax"),
    ([.Char("a"), .Char("b"), .Match], "xa"),
    ([.Char("a"), .Char("b"), .Match], "bx"),
    ([.Char("a"), .Char("b"), .Match], "xb"),
    ([.Char("a"), .Char("b"), .Match], "axb"),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], ""),
    ([.Split(1, 3), .Char("a"), .Jump(4), .Char("b"), .Match], "x"),
    ([.Split(1, 3), .Char("a"), .Jump(7), .Split(4, 6), .Char("b"), .Jump(7), .Char("c"), .Match], ""),
    ([.Split(1, 3), .Char("a"), .Jump(7), .Split(4, 6), .Char("b"), .Jump(7), .Char("c"), .Match], "x"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "bc"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "e"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "bce"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "x"),
    ([.Char("a"), .Split(2, 9), .Split(3, 6), .Char("b"), .Char("c"), .Jump(8), .Char("e"), .Split(6, 8), .Jump(1), .Match], "xe"),
])
func testEvalFail(instructions: [Instruction], target: String) async throws {
    try #expect(eval(instructions: instructions, target: target) == false)
}
