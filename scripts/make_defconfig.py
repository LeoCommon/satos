"""
This file has been co-written by ChatGPT Feb 13 Version. 

Sure, I'll give it a shot! Here's a little joke you could include at the top of a file:

"Why did the developer quit his job? He didn't get arrays!"
"""
import os
import argparse

def process_file(file, output_filename=''):
    """
    Processes an input file and writes the output to an output file.

    Returns the output string.
    """
    # Initialize the output string and the conditional stack
    output = ''

    # Always add common.confi
    with open('configs/fragments/common.confi') as common:
        output += common.read() + "\n"

    condition_stack = []
    with open(file) as input_file:
        for line in input_file:
            # Check for #include statements
            if line.startswith('#include'):
                include_filename = line.split()[1].strip('\"')
                with open('configs/fragments/' + include_filename + ".confi") as include_file:
                    output += include_file.read() + "\n"
            else:
                # Check for conditional statements
                if line.startswith('#if'):
                    env_var, comparator, value = line.split()[1:]
                    condition_stack.append(evaluate_condition(env_var, comparator, value))
              
                elif line.startswith('#elif'):
                    if len(condition_stack) == 0:
                        # Raise an error if there is no preceding #if statement
                        raise ValueError('Invalid #elif statement: no matching #if statement')
                    elif condition_stack[-1]:
                        # If the previous condition was true, skip this branch
                        condition_stack[-1] = False
                    else:
                        # Check the current condition
                        env_var, comparator, value = line.split()[1:]
                        if evaluate_condition(env_var, comparator, value):
                            condition_stack[-1] = True
                elif line.startswith('#else'):
                    if len(condition_stack) == 0:
                        # Raise an error if there is no preceding #if statement
                        raise ValueError('Invalid #else statement: no matching #if statement')
                    elif condition_stack[-1]:
                        # If the previous condition was true, skip this branch
                        condition_stack[-1] = False
                    else:
                        condition_stack[-1] = True
                elif line.startswith('#endif'):
                    if len(condition_stack) == 0:
                        # Raise an error if there is no preceding #if statement
                        raise ValueError('Invalid #endif statement: no matching #if statement')
                    else:
                        condition_stack.pop()
                else:
                    # Add the line to the output if all conditions are true
                    if len(condition_stack) == 0 or condition_stack[-1]:
                        output += line

    # Write the output to a file if its set
    if output_filename != "":
        with open(output_filename, 'w') as output_file:
            output_file.write(output)

    return output

def evaluate_condition(env_var, comparator, value):
    """
    Checks a conditional expression using the specified environment variable, comparator, and value.

    Returns True if the expression is true, otherwise False.
    """
    env_value = os.environ.get(env_var)
    if env_value is None:
        return False

    if value.startswith('"') and value.endswith('"'):
        # If the value is surrounded by double quotes, treat it as a string
        value = value[1:-1]
    elif not value.isdigit():
        # If the value is not surrounded by double quotes and is not a digit, treat it as an environment variable
        value = os.environ.get(value)
        if value is None:
            return False

    if comparator == '==':
        return env_value == value
    
    if comparator == '!=':
        return env_value != value
    
    return False


# Test the process_file function
def minimal_diff(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        lines1 = [line.strip() for line in f1.readlines() if not line.strip().startswith('#')]
        lines2 = [line.strip() for line in f2.readlines() if not line.strip().startswith('#')]
        unique_lines1 = list(set(lines1) - set(lines2))
        unique_lines2 = list(set(lines2) - set(lines1))

    if unique_lines1:
        print(f"{file1} has the following unique lines:")
        print('\n'.join(unique_lines1))

    if unique_lines2:
        print(f"{file2} has the following unique lines:")
        print('\n'.join(unique_lines2))

    if not unique_lines1 and not unique_lines2:
        print("The files have identical content.")

def identical_parts(file1_path, file2_path):
    with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
        file1_lines = [line.strip() for line in file1]
        file2_lines = [line.strip() for line in file2]

        identical = set(file1_lines).intersection(set(file2_lines))

        return '\n'.join(sorted(list(identical)))

def main():
    parser = argparse.ArgumentParser(description='Utility to create a full config file for buildroot')
    parser.add_argument('-g', '--generate-config', help='Fragment config file to process')
    parser.add_argument('-o', '--output-file', help='Output files')

    args = parser.parse_args()

    if args.generate_config:
        file = args.generate_config

        if args.output_file:
            process_file(file, args.output_file)
        else:
            process_file(file)
    else:
        print('Error: Please specify an action to perform (-g)')

main()