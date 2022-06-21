table.insert(props, {
  Name = "Debug Print",
  Type = "enum",
  Choices = {"None", "Tx/Rx", "Tx", "Rx", "Function Calls", "All"},
  Value = "None"
})
table.insert(props, {
  Name = "Connection Test Inteval",
  Type = "integer",
  Min = 1,
  Max = 60,
  Value = 5
})