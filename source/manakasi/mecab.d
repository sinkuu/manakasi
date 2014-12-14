module manakasi.mecab;

import manakasi.c.mecab;

import std.array;
import std.conv;
import std.exception;
import std.range;
import std.string;
import std.traits;


string mecabVersion() pure nothrow @property
{
	return mecab_version().to!string;
}


class Mecab
{
	private
	{
		mecab_t* _mecab;
		mecab_model_t* _model;
	}

	this(in string arg)
	{
		_model = enforce(mecab_model_new2(arg.toStringz), "Failed to create model");
		scope(failure) mecab_model_destroy(_model);

		_mecab = enforce(mecab_model_new_tagger(_model), "Failed to create mecab");
		scope(failure) mecab_destroy(_mecab);
	}

	this()
	{
		this("");
	}

	~this() nothrow @nogc
	{
		mecab_destroy(_mecab);
		mecab_model_destroy(_model);
	}

	@property auto dictionaryInfo() nothrow
	{
		auto app = appender!(immutable(DictionaryInfo)[]);

		auto info = mecab_dictionary_info(_mecab);
		while (info !is null)
		{
			app ~= DictionaryInfo(info);
			info = info.next;
		}

		return app.data;
	}

	string parseToString(S)(in S sentence)
	if (isSomeString!S)
	{
		auto lattice = mecab_model_new_lattice(_model);
		scope(exit) mecab_lattice_destroy(lattice);

		mecab_lattice_set_sentence(lattice, sentence.to!string.toStringz);

		return mecab_lattice_tostr(lattice).to!string;
	}

	private static struct Nodes(S)
	{
		private
		{
			Lattice _lattice;
			mecab_node_t* current;
		}

		this(Lattice lattice)
		{
			_lattice = lattice;
			current = enforce(mecab_lattice_get_bos_node(_lattice));
			current = current.next;

			assert(current);
		}

		this(mecab_node_t* node) @safe pure nothrow @nogc
		{
			current = node;
			if (current.stat == MECAB_BOS_NODE) current = current.next;

			assert(current);
		}

		@property bool empty() const pure @safe nothrow @nogc
		{
			return current is null || current.stat == MECAB_EOS_NODE;
		}

		@property auto front() const pure
		{
			assert(!empty);

			return Node!S(*current);
		}

		void popFront() @safe pure nothrow @nogc
		{
			assert(!empty);

			current = current.next;
		}
	}

	static assert(isInputRange!(Nodes!wstring));


	auto parseToNodes(S)(in S sentence)
	if (isSomeString!S)
	{
		return Nodes!S(new Lattice(this, sentence));
	}

	auto parseToBests(S)(in S sentence, ulong nbest = 0)
	if (isSomeString!S)
	{
		static struct Bests
		{
			private
			{
				mecab_lattice_t* _lattice;
				immutable ulong _nbest;
			}

			this(Mecab mecab, S sentence, ulong nbest) nothrow
			{
				assert(nbest > 0);
				_nbest = nbest;

				_lattice = mecab_model_new_lattice(mecab._model);

				mecab_lattice_add_request_type(_lattice, MECAB_NBEST);
				mecab_lattice_set_sentence(_lattice, sentence.to!string.toStringz);
				mecab_parse_lattice(mecab._mecab, _lattice);
			}

			~this() nothrow @nogc
			{
				mecab_lattice_destroy(_lattice);
			}

			@disable this(this);

			int opApply(int delegate(Nodes!S) dg)
			{
				int result;
				ulong idx;

				do
				{
					mecab_node_t* node = enforce(mecab_lattice_get_bos_node(_lattice));

					result = dg(Nodes!S(node));
					if (result != 0) break;

					idx++;
					if (idx >= _nbest) break;
				} while(mecab_lattice_next(_lattice));

				return result;
			}

			int opApply(int delegate(ulong, Nodes!S) dg)
			{
				int result;
				ulong idx;

				do
				{
					mecab_node_t* node = enforce(mecab_lattice_get_bos_node(_lattice));

					result = dg(idx, Nodes!S(node));
					if (result != 0) break;

					idx++;
					if (idx >= _nbest) break;
				} while(mecab_lattice_next(_lattice));

				return result;
			}

		}

		return Bests(this, sentence, nbest);
	}

	S[] segment(S)(S sentence)
	if (isSomeString!S)
	{
		import std.algorithm : map;
		return parseToNodes(sentence).map!"a.surface".array;
	}
}

enum DictionaryType
{
	system,
	user,
	unknown
}

struct DictionaryInfo
{
	string filename;
	string charset;

	uint size;
	
	DictionaryType type;

	uint lsize;
	uint rsize;

	ushort ver;

	this(const(mecab_dictionary_info_t)* info) pure nothrow
	{
		filename = info.filename.to!string;
		charset = info.charset.to!string;

		size = info.size;

		type = cast(DictionaryType) info.type;

		lsize = info.lsize;
		rsize = info.rsize;

		ver = info.version_;
	}
}

private final class Lattice
{
	private mecab_lattice_t* _lattice;

	this(S)(Mecab mecab, S sentence)
	if (isSomeString!S)
	{
		_lattice = enforce(mecab_model_new_lattice(mecab._model), "Failed to create lattice");

		mecab_lattice_set_sentence(_lattice, sentence.to!string.toStringz);
		enforce(mecab_parse_lattice(mecab._mecab, _lattice), "Failed to parse");
	}

	~this() nothrow @nogc
	{
		mecab_lattice_destroy(_lattice);
	}

	alias _lattice this;
}

enum NodeStat
{
	normal,
	unknown,
	bos,
	eos,
	eon
}

struct Node(S)
if (isSomeString!S)
{
	S surface;
	S feature;

	NodeStat stat;

	bool isBest;

	float alpha;
	float beta;
	float prob;

	short wcost;
	long cost;

	// this(mecab_node_t* node) pure
	this(in mecab_node_t node) pure
	{
		stat = cast(NodeStat) node.stat;

		isBest = cast(bool) node.isbest;

		alpha = node.alpha;
		beta = node.beta;
		prob = node.prob;

		wcost = node.wcost;
		cost = node.cost;

		surface = node.surface[0 .. node.length].to!S;

		import core.stdc.string : strlen;
		feature = node.feature[0 .. strlen(node.feature)].to!S;
	}
}

version (TestMecab) unittest
{
	auto mecab = new Mecab;
	assert(mecab.segment("こんにちは世界"d).length != 0);
	assert(mecab.segment("こんにちは世界"w).length != 0);
	assert(mecab.segment("こんにちは世界").length != 0);

	assert(!mecab.parseToNodes("こんにちは世界"d).empty);
	assert(!mecab.parseToNodes("こんにちは世界"w).empty);
	assert(!mecab.parseToNodes("こんにちは世界").empty);
}



private Mecab globalMecab;

Mecab getMecab()
{
	if (globalMecab is null)
	{
		globalMecab = new Mecab;
	}

	return globalMecab;
}


S[] segment(S)(in S sentence)
if (isSomeString!S)
{
	return getMecab().segment(sentence);
}

string parseToString(S)(in S sentence)
if (isSomeString!S)
{
	return getMecab().parseToString(sentence);
}

auto parseToNodes(S)(in S sentence)
if (isSomeString!S)
{
	return getMecab().parseToNodes(sentence);
}

auto parseToBests(S)(in S sentence, ulong nbest = 0)
if (isSomeString!S)
{
	return getMecab().parseToBests(sentence, nbest);
}

