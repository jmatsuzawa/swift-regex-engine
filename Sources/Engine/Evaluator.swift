enum EvalError: Error {
    case InvalidPc
}


func evalDepth(
    instructions: [Instruction],
    target: String,
    pc pcInput: Int,
    sp spInput: Int
) throws -> Bool {
    var pc = pcInput // Program Counter Register
    var sp = spInput // String Pointer Register
    while true {
        if pc < 0 || instructions.count <= pc {
            throw EvalError.InvalidPc
        }
        switch instructions[pc] {
        case .Char(let c):
            if sp >= target.count {
                return false
            }
            // get character at currentSp in target
            let charAtSp = target[target.index(target.startIndex, offsetBy: sp)]
            if c == charAtSp {
                pc += 1
                sp += 1
            } else {
                return false
            }
        case .Match:
            return true
        case .Jump(let newPc):
            pc = newPc
        case .Split(let pc1, let pc2):
            if try evalDepth(instructions: instructions, target: target, pc: pc1, sp: sp) ||
                evalDepth(instructions: instructions, target: target, pc: pc2, sp: sp)
            {
                return true
            }
            return false
        }
    }
}

func eval(
    instructions: [Instruction],
    target: String
) throws -> Bool {
    var wkTarget = target
    while true {
        if try evalDepth(instructions: instructions, target: wkTarget, pc: 0, sp: 0) == true {
            return true
        }
        if wkTarget.count == 0 {
            break
        }
        let subString = wkTarget[wkTarget.index(after: wkTarget.startIndex)...]
        wkTarget = String(subString)
    }
    return false
}
