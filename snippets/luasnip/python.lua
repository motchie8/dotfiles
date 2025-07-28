local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"args",
		fmt(
			[[
import argparse
parser = argparse.ArgumentParser()
parser.add_argument(
	"--{}",
	type={},
)
args = parser.parse_args()
            ]],
			{ i(1, "key"), i(2, "type") }
		)
	),
	s(
		"arg",
		fmt(
			[[
parser.add_argument(
	"--{}",
	type={},
)
            ]],
			{ i(1, "key"), i(2, "type") }
		)
	),
	s(
		"def",
		fmt(
			[[
def {}({}: {}) -> {}:
	"""description

	Args:
		{} ({}): description

	Returns:
		{}: description

	Examples:
		>>> {}({}=...)
		"value"
	"""
            ]],
			{ i(1, "func"), i(2, "arg1"), i(3, "type"), i(4, "type"), i(2), i(3), i(4), i(1), i(2) }
		)
	),
	s(
		"defn",
		fmt(
			[[
def {}({}: {}) -> {}:
	"""description

	Parameters
	-------
	{} : {}
		description

	Returns
	-------
	{}
		description

	Examples
	------
	>>> {}({}=...)
	"value"
	"""
            ]],
			{ i(1, "func"), i(2, "arg1"), i(3, "type"), i(4, "type"), i(2), i(3), i(4), i(1), i(2) }
		)
	),
	s(
		"assert",
		fmt(
			[[
unittest.TestCase().assertDictEqual({}, {})
            ]],
			{ i(1, "expected"), i(2, "actual") }
		)
	),
	s(
		"unionfind",
		t([[from dataclasses import dataclass, field
from typing import List
@dataclass
class UnionFind:
	node_size: int
	parent_indices: List[int] = field(init=False)

	def __post_init__(self) -> None:
		self.parent_indices = [-1] * self.node_size

	def root(self, idx: int) -> int:
		if self.parent_indices[idx] < 0:
			return idx
		root_idx = self.root(idx=self.parent_indices[idx])
		self.parent_indices[idx] = root_idx
		return root_idx

	def size(self, idx: int) -> int:
		root_idx = self.root(idx=idx)
		group_size = abs(self.parent_indices[root_idx])
		return group_size

	def merge(self, idx_a: int, idx_b: int) -> None:
		a_root = self.root(idx=idx_a)
		b_root = self.root(idx=idx_b)
		if a_root == b_root >= 0:
			return
		if self.parent_indices[a_root] > self.parent_indices[b_root]:
			a_root, b_root = b_root, a_root
		self.parent_indices[a_root] += self.parent_indices[b_root]
		self.parent_indices[b_root] = a_root

	def issame(self, idx_a: int, idx_b: int) -> bool:
		a_root = self.root(idx=idx_a)
		b_root = self.root(idx=idx_b)
		return a_root == b_root]])
	),
	s(
		"binary_search",
		t([[from typing import List, Optional

def binary_search(sorted_array: List[int], value: int, left: Optional[int]=None, right: Optional[int]=None) -> Optional[int]:
	if left is None:
		left = 0
	if right is None:
		right = len(sorted_array)
	pivot = left + int((right - left) / 2)
	if sorted_array[pivot] == value:
		return pivot
	elif right - left == 1:
		return None
	elif sorted_array[pivot] > value:
		return binary_search(sorted_array=sorted_array, value=value, left=left, right=pivot)
	else:
		return binary_search(sorted_array=sorted_array, value=value, left=pivot+1, right=right)]])
	),
	s(
		"spark",
		t([[from pyspark.sql import SparkSession

spark = (SparkSession
    .builder
    .master("local")
    .appName("MyApp")
    .getOrCreate()
)]])
	),
	s(
		"dummy_input",
		fmt(
			[[
from collections import deque
from pathlib import Path
input_queue = deque()

def input(n: int = 1) -> str:
	if len(input_queue) == 0:
		test_input_path = Path(__file__).parent / 'test' / f'sample-{}.in'
		lines = test_input_path.read_text().split('\n')
		for l in lines:
			input_queue.append(l)
	return input_queue.popleft()
            ]],
			{ i(1, "n") }
		)
	),
	s(
		"recursion_limit",
		t([[import sys
sys.setrecursionlimit(100000)]])
	),
}
