package account

import rego.v1

default allow := false

allow if {
 creditor_is_valid
 debtor_is_valid
 period_is_valid
 amount_is_valid
}
creditor_is_valid if data.account.account_attributes[input.creditor_account].owner == input.creditor
debtor_is_valid if data.account.account_attributes[input.debtor_account].owner == input.debtor

period_is_valid if input.period <= 30
amount_is_valid if data.account.account_attributes[input.debtor_account].amount >= input.amount
