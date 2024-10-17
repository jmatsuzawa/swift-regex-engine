public func match(expr: String, target: String) throws -> Bool {
    let ast = try parse(expr: expr)

    var generator = Generator()
    let instructions = try generator.generateCode(ast: ast)

    return try eval(instructions: instructions, target: target)
}
