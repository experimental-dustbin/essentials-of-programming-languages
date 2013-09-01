require_relative './values'

module LetGrammar

  ##
  # All the binary operator classes have a very generic structure
  # when it comes to evaluation. So abstract the class creation
  # and evaluation method definition.

  def self.binary_operator_class(ast_class, operator, eval_result_class)
    klass = const_set(ast_class, Class.new(Struct.new(:first, :second)))
    klass.class_eval do
      define_method(:eval) do |env|
        first_result = first.eval(env).value
        second_result = second.eval(env).value
        eval_result_class.new(first_result.send(operator, second_result))
      end
    end
  end

  ##
  # Numeric binary operator definitions

  [[:Diff, :-], [:Add, :+], [:Mult, :*], [:Div, :/]].each do |op_def|
    binary_operator_class(*op_def, NumVal)
  end

  ##
  # Boolean binary operator definitions

  [[:EqualTo, :==], [:GreaterThan, :>], [:LessThan, :<]].each do |op_def|
    binary_operator_class(*op_def, BoolVal)
  end

  ##
  # Currently only one type of constant exists, i.e. a number

  class Const < Struct.new(:value)
    def eval(env)
      NumVal.new(value)
    end
  end

  ##
  # Variable

  class Var < Struct.new(:value)
    def eval(env)
      env[value]
    end
  end

  ##
  # Unary minus

  class Minus < Struct.new(:value)
    def eval(env)
      NumVal.new(value.eval(env).value)
    end
  end

  ##
  # Zero test

  class Zero < Struct.new(:value)
    def eval(env)
      value.eval(env).value.zero? ? BoolVal.new(true) : BoolVal.new(false)
    end
  end

  ##
  # Usual if expression

  class If < Struct.new(:test, :then, :else)
    def eval(env)
      test.eval(env).value == true ?
       self.then.eval(env) : self.else.eval(env)
    end
  end

  ##
  # Bind variables to expressions

  class Let < Struct.new(:var, :value, :body)
    def eval(env)
      env[var.value] = value.eval(env); body.eval(env)
    end
  end

end
