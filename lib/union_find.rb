class UnionFind

	def initialize
		@items = {}
	end

	def union(a, b)
		pa = find(a)
		pb = find(b)
		@items[pa] = pb
	end

	def find(i)
		@items[i] = i unless @items.key?(i)
		p = @items[i]
		return i unless p != i
		p = find(p)
		@items[i] = p
		p
	end

	def groups
		gs = {}
		@items.keys.each {
			|key| 
			value = find(key)
			gs[value] = [] unless gs.key?(value)
			gs[value] << key
		}
		gs.values
	end
end