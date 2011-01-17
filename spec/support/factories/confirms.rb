# coding: utf-8

Factory.sequence :confirm_name do |n|
  "ConfirmTest #{n}"
end

Factory.define :confirm do |f|
  f.name { Factory.next(:confirm_name) }
end

