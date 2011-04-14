class Node
  attr_accessor :token, :tag
  def initialize(aToken,aTag)
    @token = aToken
    @tag = aTag
  end

end

class NodeTree
  attr_accessor :tree

  def initialize
    @tree = []
  end

  def addToTree(n)
    if n.class == Node then
      addOneNode(n)
    elsif n.class == NodeTree or n.class == Array then
      addBulkToTree(n)
    else
      puts "Not correct data type"
    end
  end

  def addOneNode(n)
    @tree.push(n)
  end

  def addBulkToTree(t)
    t.each do |node|
      @tree.push(node)
    end
  end

  def printTree()
    @tree.each do |node|
      puts "#{node.token} => #{node.tag}"
    end
  end

end
