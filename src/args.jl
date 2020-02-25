"Parse command line arguments"
function parse_commandline()
    setting = ArgParseSettings()

    @add_arg_table! setting begin
        "--size", "-s"
            dest_name="size"
            help="size of the Cayley tree"
            arg_type=Int
            default=5
        "--num", "-n"
            dest_name="num"
            help="number of trees to generate"
            arg_type=Int
            default=1
        "--log-size", "-l"
            dest_name="log_size"
            help="log base 10 of the size of the tree"
            arg_type=Int
        "--height", "-g"
            dest_name="tall"
            help="height of the tree (only takes effect for full d-ary trees)"
            arg_type=Int
            default=0
        "--tree", "-t"
            dest_name="tree_type"
            help="type of tree: " * join(keys(TREE_DICT), ", ")
            arg_type=String
            default="Cayley"
        "--seed", "-e"
            dest_name="seed"
            help="seed for random number generators"
            arg_type=Int
        "-d"
            dest_name="d"
            help="d-ary tree"
            arg_type=Int
        "kcut"
            action = :command
            help="simulation of the k-cut number"
        "log-prod"
            action = :command
            help="simulation of log product of subtree sizes"
        "leaf"
            action = :command
            help="simulation of the number of leaves coutning"
        "height"
            action = :command
            help="simulation of the height"
        "total-path"
            action = :command
            help="simulation of the total path length"
    end

    @add_arg_table! setting["kcut"] begin
        "-k" 
            dest_name="k"
            help="k-records"
            arg_type=Int
            default=2
        "--segment", "-g"
            dest_name="segment"
            help="number of segments to track"
            arg_type=Int
            default=0
    end

    @add_arg_table! setting["log-prod"] begin
        "--pow", "-p" 
            dest_name="pow"
            help="log(subtree size)^pow"
            arg_type=Int
            default=1
    end
    return parse_args(setting)
end
