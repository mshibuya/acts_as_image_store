# coding: utf-8

Factory.sequence :multiple_name do |n|
  "Test #{n}"
end

Factory.define :multiple do |f|
  f.title { Factory.next(:multiple_name) }
end

