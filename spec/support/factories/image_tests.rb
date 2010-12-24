# coding: utf-8

Factory.sequence :image_test_name do |n|
  "Test #{n}"
end

Factory.define :image_test do |f|
  f.name { Factory.next(:image_test_name) }
end

