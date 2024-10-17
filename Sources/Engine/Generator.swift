enum Instruction: Equatable {
    case Char(Character) // char c
    case Match           // match
    case Jump(Int)       // jump pc
    case Split(Int, Int) // split pc1, pc2
}

enum CodeGenerationError: Error {
    case FailStar
    case FailOr
    case FailQuestion
}

struct Generator {
    var pc: Int // Next instruction address
    var instructions: [Instruction]

    init() {
        self.pc = 0
        self.instructions = []
    }

    mutating func incrementPc() {
        self.pc += 1
    }

    mutating func generateChar(_ c: Character) {
        self.instructions.append(.Char(c))
        self.incrementPc()
    }

    /// split L1, L2
    /// L1: e code
    /// L2:
    mutating func generateQuestion(_ e: AST) throws {
        // split L1, L2
        let splitAddr = self.pc // to be used to set L2 address
        self.incrementPc()
        let split = Instruction.Split(self.pc, 0) // L2は仮に0とする
        self.instructions.append(split)

        // L1: e code
        try self.generateExpression(ast: e)

        // L2
        if case .Split(let l1, _) = self.instructions[splitAddr] {
            self.instructions[splitAddr] = .Split(l1, self.pc)
        } else {
            throw CodeGenerationError.FailQuestion
        }
    }

    mutating func generateStar(_ e: AST) throws {
        // split L1, L2
        let splitAddr = self.pc // to be used to set L2 address
        self.incrementPc()
        let split = Instruction.Split(self.pc, 0) // L2 to be determined
        self.instructions.append(split)

        // L2: e code
        try self.generateExpression(ast: e)

        // jmp L1
        self.instructions.append(.Jump(splitAddr))
        self.incrementPc()

        // L2
        if case .Split(let l1, _) = self.instructions[splitAddr] {
            self.instructions[splitAddr] = .Split(l1, self.pc)
        } else {
            throw CodeGenerationError.FailStar
        }
    }

    mutating func generatePlus(_ e: AST) throws {
        let eAddress = self.pc
        try generateExpression(ast: e)

        // split L1, L2
        self.incrementPc()
        self.instructions.append(.Split(eAddress, self.pc))
    }


    /// split L1, L2
    /// L1: e1 code
    ///     jmp L3
    /// L2: e2 code
    /// L3:
    mutating func generateOr(_ e1: AST, _ e2: AST) throws {
        // split L1, L2
        let splitAddr = self.pc // to be used to set L2 address
        self.incrementPc()
        let split = Instruction.Split(self.pc, 0) // L2 to be determined
        self.instructions.append(split)

        // L1: e1 code
        try self.generateExpression(ast: e1)

        // jmp L3
        let jumpAddr = self.pc
        self.instructions.append(.Jump(0)) // L3 is to be determined

        self.incrementPc() // L2 address
        if case .Split(let l1, _) = self.instructions[splitAddr] {
            self.instructions[splitAddr] = .Split(l1, self.pc)
        } else {
            throw CodeGenerationError.FailOr
        }

        // L2: e2 code
        try self.generateExpression(ast: e2)

        // L3 address
        if case .Jump(_) = self.instructions[jumpAddr] {
            self.instructions[jumpAddr] = .Jump(self.pc)
        } else {
            throw CodeGenerationError.FailOr
        }
    }

    mutating func generateSeq(_ asts: [AST]) throws {
        for ast in asts {
            try self.generateExpression(ast: ast)
        }
    }

    mutating func generateExpression(ast: AST) throws {
        switch ast {
        case .Char(let c):
            self.generateChar(c)
        case .Star(let e):
            try self.generateStar(e)
        case .Plus(let e):
            try self.generatePlus(e)
        case .Question(let e):
            try self.generateQuestion(e)
        case .Or(let e1, let e2):
            try self.generateOr(e1, e2)
        case .Seq(let asts):
            try self.generateSeq(asts)
        }
    }

    mutating func generateCode(ast: AST) throws -> [Instruction] {
        try self.generateExpression(ast: ast)
        self.instructions.append(.Match)
        self.incrementPc()
        return self.instructions
    }
}
