indirect enum AST: Equatable, Sendable {
    case Char(Character)
    case Plus(AST)
    case Star(AST)
    case Question(AST)
    case Or(AST, AST)
    case Seq([AST])
}

enum PSQ {
    case Plus
    case Star
    case Question
}

enum ParseError: Error, Equatable {
    case UnexpectedEndOfInput
    case InvalidQuantifier
    case InvalidCharacter(Character)
    case NoRightParen
    case Empty
}

/// Convert quantifier '+', '*', '?' to AST
func parsePlusStarQuestion(seq: inout [AST], astType: PSQ) throws {
    if let last = seq.popLast() {
        let ast = switch astType {
            case .Plus: AST.Plus(last)
            case .Star: AST.Star(last)
            case .Question: AST.Question(last)
        }
        seq.append(ast)
    } else {
        throw ParseError.InvalidQuantifier
    }
}

func foldOr(_ seq: inout [AST]) throws -> AST {
    if seq.count < 1 {
        throw ParseError.Empty
    }
    if seq.count == 1 {
        return seq[0]
    }
    var ast = seq.popLast()!
    seq.reverse()
    for a in seq {
        ast = .Or(a, ast)
    }
    return ast;
}

func parse(expr: String) throws -> AST {
    enum ParseState{
        case Char
        case Escape
    }

    var seq: [AST] = []
    var seqOr: [AST] = []
    var stack: [([AST], [AST])] = []
    var state = ParseState.Char

    for c in expr {
        switch state {
        case .Char:
            switch c {
            case "+":
                try parsePlusStarQuestion(seq: &seq, astType: .Plus)
            case "*":
                try parsePlusStarQuestion(seq: &seq, astType: .Star)
            case "?":
                try parsePlusStarQuestion(seq: &seq, astType: .Question)
            case "(":
                stack.append((seq, seqOr))
                seq = []
                seqOr = []
            case ")":
                if stack.isEmpty {
                    throw ParseError.InvalidCharacter(c)
                }
                var (prevSeq, prevSeqOr) = stack.popLast()!
                if !seq.isEmpty {
                    seqOr.append(.Seq(seq))
                }
                prevSeq.append(try foldOr(&seqOr))
                seq = prevSeq
                seqOr = prevSeqOr
            case "|":
                if seq.isEmpty {
                    throw ParseError.InvalidCharacter(c)
                }
                seqOr.append(.Seq(seq))
                seq = []
            case "\\":
                state = .Escape
            default:
                seq.append(.Char(c))
            }
        case .Escape:
            seq.append(.Char(c))
            state = .Char
        }
    }
    if !stack.isEmpty {
        throw ParseError.NoRightParen
    }
    if !seq.isEmpty {
        seqOr.append(.Seq(seq))
    }
    return try foldOr(&seqOr)
}
