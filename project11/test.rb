#!/usr/bin/ruby
require 'rubygems'
require 'ruby-debug'
require 'CompilationEngine'
require 'JackTokenizer'
require 'Node'

x = "(1+(2*3))"

x = [
  ["(",:symbol],
  [1,:integerConstant],
  ["+", :symbol],
  ["(",:symbol],
  [2,:integerConstant],
  ["*",:symbol],
  [3,:integerConstant],
  [")",:symbol],
  [")",:symbol],
  ]

outputFile2 = File.new("test.xml","w")

parseTokensFile = Builder::XmlMarkup.new(:target => outputFile2, :indent => 2 )
tree = NodeTree.new(x)
x.each do |n|
  node = Node.new(n[0],n[1])
  tree.addToTree(node)
end

# tree.printTree
c = CompilationEngine.new(tree,parseTokensFile,outputFile2)
# c.createExp(tree)
# puts x.inspect