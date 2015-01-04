import manakasi.mecab;

import std.stdio;

void main()
{
	auto mecab = new Mecab;

	writeln(mecab.segment("すもももももももものうち"w));

	foreach(n, nodes; mecab.parseToBests("吾輩は猫である。", 3))
	{
		writeln(n + 1, " best:");

		foreach(node; nodes)
		{
			writeln(node.surface, "\t", node.feature);
		}
	}
}
