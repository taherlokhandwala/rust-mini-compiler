import re
import sys

if len(sys.argv) != 2:
    print("Correct usage: Enter filename\n")
    exit()

icg_file = sys.argv[1]


def istemp(s):
    return bool(re.match(r"^t[0-9]*$", s))


def isid(s):
    return bool(re.match(r"^[A-Za-z][A-Za-z0-9_]*$", s))


binary_operators = {"+", "-", "*", "/", "*", "&",
                    "|", "^", "==", ">=", "<=", "!=", ">", "<"}


def printicg(list_of_lines, message=""):
    print(message.upper())
    for line in list_of_lines:
        print(line.strip())


def eval_wrap(line):
    tokens = line.split()
    if len(tokens) != 5:
        return line
    if tokens[1] != "=" or tokens[3] not in binary_operators:
        return line
    try:
        if tokens[3] == '/' and tokens[4] == "0":
            print("Division By Zero is undefined")
            quit()
        elif tokens[2].isdigit() and tokens[4].isdigit():
            result = int(eval(str(tokens[2] + tokens[3] + tokens[4])))
            return " ".join([tokens[0], tokens[1], str(result)])

        return " ".join(tokens)
    except NameError:
        return line
    return line


def fold_constants(list_of_lines):
    new_list_of_lines = []
    for line in list_of_lines:
        new_list_of_lines.append(eval_wrap(line))
    return new_list_of_lines


def remove_dead_code(list_of_lines):
    num_lines = len(list_of_lines)
    temps_on_lhs = set()
    for line in list_of_lines:
        tokens = line.split()
        if istemp(tokens[0]):
            temps_on_lhs.add(tokens[0])

    useful_temps = set()
    for line in list_of_lines:
        tokens = line.split()
        if len(tokens) >= 2:
            if istemp(tokens[1]):
                useful_temps.add(tokens[1])
        if len(tokens) >= 3:
            if istemp(tokens[2]):
                useful_temps.add(tokens[2])
    temps_to_remove = temps_on_lhs - useful_temps

    new_list_of_lines = []
    for line in list_of_lines:
        tokens = line.split()
        if tokens[0] not in temps_to_remove:
            new_list_of_lines.append(line)
    if num_lines == len(new_list_of_lines):
        return new_list_of_lines
    return remove_dead_code(new_list_of_lines)


def make_subexpression_dict(list_of_lines):
    expressions = {}
    variables = {}
    for line in list_of_lines:
        tokens = line.split()
        if len(tokens) == 5:
            rhs = tokens[2] + " " + tokens[3] + " " + tokens[4]
            if rhs not in expressions:
                expressions[rhs] = tokens[0]
                if isid(tokens[2]):
                    variables[tokens[2]] = rhs
                if isid(tokens[4]):
                    variables[tokens[4]] = rhs
    return expressions


def eliminate_common_subexpressions(list_of_lines):
    expressions = make_subexpression_dict(list_of_lines)
    # print(expressions)
    lines = len(list_of_lines)
    new_list_of_lines = list_of_lines[:]
    for i in range(lines):
        tokens = list_of_lines[i].split()
        if len(tokens) == 5:
            rhs = tokens[2] + " " + tokens[3] + " " + tokens[4]
            if rhs in expressions and expressions[rhs] != tokens[0]:
                new_list_of_lines[i] = tokens[0] + " " + \
                    tokens[1] + " " + expressions[rhs]
    return new_list_of_lines


if __name__ == "__main__":

    if len(sys.argv) == 2:
        icg_file = str(sys.argv[1])

    list_of_lines = []
    f = open(icg_file, "r")
    for line in f:
        list_of_lines.append(line)
    f.close()

    printicg(list_of_lines, "ICG")
    print("\n")

    eliminated_common_subexpressions = eliminate_common_subexpressions(
        list_of_lines)
    print("\n")

    printicg(eliminated_common_subexpressions,
             "Optimized ICG after eliminating common subexpressions")
    print("\n")

    folded_constants = fold_constants(eliminated_common_subexpressions)
    printicg(folded_constants, "Optimized ICG after constant folding")
    print("\n")

    without_deadcode = remove_dead_code(folded_constants)
    printicg(without_deadcode, "Optimized ICG after removing dead code")

    print("\n")
    print("Eliminated", len(list_of_lines) -
          len(without_deadcode), "lines of code")
    print("\n")
