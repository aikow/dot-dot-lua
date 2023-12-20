local Tester = {}

function Tester.assert_eq(expected, actual, message)
  if expected ~= actual then
    local msg = string.format(
      "Assertion error: '%s' ~= '%s'\nActual: '%s' = %s",
      expected,
      actual,
      expected,
      actual,
      message
    )
    error(msg, 2)
  end
end

---Test a method for all given parameters.
---@param fn function
---@param arguments { ["1"]: any, ["2"]: any[] }[]
---@param format string
function Tester.test_function_arguments(fn, arguments, format)
  for i, testcase in ipairs(arguments) do
    local expected, args = table.unpack(testcase)
    local actual = fn(table.unpack(args))
    Tester.assert_eq(expected, actual, format:format(table.unpack(arguments)))
  end
end

function Tester.test_module(module) end

return Tester
