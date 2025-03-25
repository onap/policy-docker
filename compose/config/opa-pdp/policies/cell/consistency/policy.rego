package cell.consistency
import rego.v1
default allow = false
# Rule to check cell consistency
check_cell_consistency if {
    input.cell != data.node.cell.consistency.allowedCellId
}
# Rule to allow if PCI is within range 1-3000
allow_if_pci_in_range  if {
    input.PCI >= data.node.cellconsistency.minPCI
    input.PCI <= data.node.cellconsistency.maxPCI
}
# Main rule to determine the final decision
allow  if{
    check_cell_consistency
    allow_if_pci_in_range
}
