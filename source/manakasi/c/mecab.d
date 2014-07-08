module manakasi.c.mecab;

import core.stdc.config : c_long;

struct mecab_dictionary_info_t
{
	const char* filename;

	const char* charset;

	uint size;

	int type;

	uint lsize;

	uint rsize;

	ushort version_;

	mecab_dictionary_info_t* next;
}


struct mecab_path_t
{
	mecab_node_t* rnode;

	mecab_path_t* rnext;

	mecab_node_t* lnode;

	mecab_path_t* lnext;

	c_long cost;
}


struct mecab_node_t
{
	mecab_node_t* prev;
	
	mecab_node_t* next;

	mecab_node_t* enext;

	mecab_node_t* bnext;

	mecab_path_t* rpath;

	mecab_path_t* lpath;

	const char* surface;

	const char* feature;

	uint id;

	ushort length;

	ushort rlength;

	ushort rcAttr;

	ushort lcAttr;

	ushort posid;

	ubyte char_type;

	ubyte stat;

	ubyte isbest;

	float alpha;

	float beta;

	float prob;

	short wcost;

	long cost;
}


enum MECAB_NOR_NODE = 0;

enum MECAB_UNK_NODE = 1;

enum MECAB_BOS_NODE = 2;

enum MECAB_EOS_NODE = 3;

enum MECAB_EON_NODE = 4;


enum MECAB_SYS_DIC = 0;

enum MECAB_USR_DIC = 1;

enum MECAB_UNK_DIC = 2;


enum MECAB_ONE_BEST          = 0b0000001;

enum MECAB_NBEST             = 0b0000010;

enum MECAB_PARTIAL           = 0b0000100;

enum MECAB_MARGINAL_PROB     = 0b0001000;

enum MECAB_ALTERNATIVE       = 0b0010000;

enum MECAB_ALL_MORPHS        = 0b0100000;

enum MECAB_ALLOCATE_SENTENCE = 0b1000000;


enum MECAB_ANY_BOUNDARY = 0;

enum MECAB_TOKEN_BOUNDARY = 1;

enum MECAB_INSIDE_TOKEN = 2;


struct mecab_t { }

struct mecab_model_t { }

struct mecab_lattice_t { }

extern(C) nothrow @nogc:

mecab_t* mecab_new(int argc, char** argv);

mecab_t* mecab_new2(const char* arg);

pure @safe const(char)* mecab_version();

const(char)* mecab_strerror(mecab_t* mecab);

void mecab_destroy(mecab_t* mecab);

int mecab_get_partial(mecab_t* mecab);

void mecab_set_partial(mecab_t* mecab, int partial);

float mecab_get_theta(mecab_t* mecab);

void mecab_set_theta(mecab_t* mecab, float theta);

int mecab_get_lattice_level(mecab_t* mecab);

void mecab_set_lattice_level(mecab_t* mecab, int level);

int mecab_get_all_morphs(mecab_t* mecab);

void mecab_set_all_morphs(mecab_t* mecab, int all_morphs);

int mecab_parse_lattice(mecab_t* mecab, mecab_lattice_t* lattice);

const(char)* mecab_sparse_tostr(mecab_t* mecab, const char* str);

const(char)* mecab_sparse_tostr2(mecab_t* mecab, const char* str, size_t len);

char* mecab_sparse_tostr3(mecab_t* mecab, const char* str, size_t len,
		char* ostr, size_t olen);

const(mecab_node_t)* mecab_sparse_tonode(mecab_t* mecab, const char*);

const(mecab_node_t)* mecab_sparse_tonode2(mecab_t* mecab, const char*, size_t);

const(char)* mecab_nbest_sparse_tostr(mecab_t* mecab, size_t N, const char* str);

const(char)* mecab_nbest_sparse_tostr2(mecab_t* mecab, size_t N,
		const char* str, size_t len);

char* mecab_nbest_sparse_tostr3(mecab_t* mecab, size_t N,
		const char* str, size_t len,
		char* ostr, size_t olen);

int mecab_nbest_init(mecab_t* mecab, const char* str);

int mecab_nbest_init2(mecab_t* mecab, const char* str, size_t len);

const(char)* mecab_nbest_next_tostr(mecab_t* mecab);

char* mecab_nbest_next_tostr2(mecab_t* mecab, char* ostr, size_t olen);

const(mecab_node_t)* mecab_nbest_next_tonode(mecab_t* mecab);

const(char)*   mecab_format_node(mecab_t* mecab, const mecab_node_t* node);

const(mecab_dictionary_info_t)* mecab_dictionary_info(mecab_t* mecab);


mecab_lattice_t* mecab_lattice_new();

void mecab_lattice_destroy(mecab_lattice_t* lattice);

void mecab_lattice_clear(mecab_lattice_t* lattice);

int mecab_lattice_is_available(mecab_lattice_t* lattice);

mecab_node_t* mecab_lattice_get_bos_node(mecab_lattice_t* lattice);

mecab_node_t* mecab_lattice_get_eos_node(mecab_lattice_t* lattice);

mecab_node_t** mecab_lattice_get_all_begin_nodes(mecab_lattice_t* lattice);

mecab_node_t** mecab_lattice_get_all_end_nodes(mecab_lattice_t* lattice);

mecab_node_t* mecab_lattice_get_begin_nodes(mecab_lattice_t* lattice, size_t pos);

mecab_node_t* mecab_lattice_get_end_nodes(mecab_lattice_t* lattice, size_t pos);

const(char)* mecab_lattice_get_sentence(mecab_lattice_t* lattice);

void mecab_lattice_set_sentence(mecab_lattice_t* lattice, const char* sentence);

void mecab_lattice_set_sentence2(mecab_lattice_t* lattice, const char* sentence, size_t len);

size_t mecab_lattice_get_size(mecab_lattice_t* lattice);

double mecab_lattice_get_z(mecab_lattice_t* lattice);

void mecab_lattice_set_z(mecab_lattice_t* lattice, double Z);

double mecab_lattice_get_theta(mecab_lattice_t* lattice);

void mecab_lattice_set_theta(mecab_lattice_t* lattice, double theta);

int mecab_lattice_next(mecab_lattice_t* lattice);

int mecab_lattice_get_request_type(mecab_lattice_t* lattice);

int mecab_lattice_has_request_type(mecab_lattice_t* lattice, int request_type);

void mecab_lattice_set_request_type(mecab_lattice_t* lattice, int request_type);

void mecab_lattice_add_request_type(mecab_lattice_t* lattice, int request_type);

void mecab_lattice_remove_request_type(mecab_lattice_t* lattice, int request_type);

mecab_node_t* mecab_lattice_new_node(mecab_lattice_t* lattice);

const(char)* mecab_lattice_tostr(mecab_lattice_t* lattice);

const(char)* mecab_lattice_tostr2(mecab_lattice_t* lattice, char* buf, size_t size);

const(char)* mecab_lattice_nbest_tostr(mecab_lattice_t* lattice, size_t N);

const(char)* mecab_lattice_nbest_tostr2(mecab_lattice_t* lattice, size_t N, char* buf, size_t size);

int mecab_lattice_has_constraint(mecab_lattice_t* lattice);

int mecab_lattice_get_boundary_constraint(mecab_lattice_t* lattice, size_t pos);

const(char)* mecab_lattice_get_feature_constraint(mecab_lattice_t* lattice, size_t pos);

void mecab_lattice_set_boundary_constraint(mecab_lattice_t* lattice, size_t pos, int boundary_type);

void mecab_lattice_set_feature_constraint(mecab_lattice_t* lattice, size_t begin_pos, size_t end_pos, const char* feature);

void mecab_lattice_set_result(mecab_lattice_t* lattice, const char* result);

const(char)* mecab_lattice_strerror(mecab_lattice_t* lattice);

mecab_model_t* mecab_model_new(int argc, char** argv);

mecab_model_t* mecab_model_new2(const char* arg);

void mecab_model_destroy(mecab_model_t* model);

mecab_t* mecab_model_new_tagger(mecab_model_t* model);

mecab_lattice_t* mecab_model_new_lattice(mecab_model_t* model);

int mecab_model_swap(mecab_model_t* model, mecab_model_t* new_model);

const(mecab_dictionary_info_t)* mecab_model_dictionary_info(mecab_model_t* model);

int mecab_model_transition_cost(mecab_model_t* model,
		ushort rcAttr,
		ushort lcAttr);

mecab_node_t* mecab_model_lookup(mecab_model_t* model,
		const char* begin,
		const char* end,
		mecab_lattice_t* lattice);

int mecab_do(int argc, char** argv);
int mecab_dict_index(int argc, char** argv);
int mecab_dict_gen(int argc, char** argv);
int mecab_cost_train(int argc, char** argv);
int mecab_system_eval(int argc, char** argv);
int mecab_test_gen(int argc, char** argv);

