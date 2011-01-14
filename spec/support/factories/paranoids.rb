# coding: utf-8

Factory.sequence :paranoid_name do |n|
  "Paranoid Test #{n}"
end

Factory.define :paranoid do |f|
  f.name { Factory.next(:paranoid_name) }
end

