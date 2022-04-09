CC = /usr/bin/gcc
FLEX = /usr/bin/flex
BISON = /usr/bin/bison

CFLAGS = -Wall
FLEX_CFLAGS = $(CFLAGS) -lfl

src = main.c C--syntax.tab.c syntax_tree.c sema.c \
	sematic/sema_util.c sematic/sema_error.c sematic/symbol_schema.c sematic/field_list.c \
	sematic/table_item.c sematic/hash_table.c sematic/stack.c sematic/symbol_table.c

# 日志输出函数
define echo_info
    @echo "\033[34m$(1)\033[0m"
endef
define echo_success
    @echo "\033[32m$(1)\033[0m"
endef


# 编译C--分析器
parser:
	$(call echo_info,"Generating syntax analyzer...")
	$(BISON) -d C--syntax.y
	$(call echo_info,"Generating lexical analyzer...")
	$(FLEX) -o C--lexical.yy.c C--lexical.l
	$(call echo_info,"GCC compiling...")
	$(CC) $(FLEX_CFLAGS) \
		-o C--parser $(src)
	$(call echo_success,"Done.")

parser-debug:
	$(call echo_info,"Generating syntax analyzer...")
	$(BISON) -d -t -v C--syntax.y
	$(call echo_info,"Generating lexical analyzer...")
	$(FLEX) -o C--lexical.yy.c C--lexical.l
	$(call echo_info,"GCC compiling...")
	$(CC) $(FLEX_CFLAGS) -D DEBUG -D YYDEBUG=1 \
		-g \
		-o C--parser-debug $(src)
	$(call echo_success,"Done.")

.PHONY: examples test clean

# 编译全部示例代码
examples:
	$(call echo_info,"Building count...")
	cd examples && $(FLEX) -o count.yy.c count.l
	cd examples && $(CC) $(FLEX_CFLAGS) count.yy.c -o count
	$(call echo_success,"Done.")

	$(call echo_info,"Building calc...")
	cd examples && $(BISON) -d calc.y
	cd examples && $(FLEX) -o calc.yy.c calc.l
	cd examples && $(CC) $(FLEX_CFLAGS) -o calc calc.tab.c calc.yy.c
	$(call echo_success,"Done.")

# 运行单元测试
test:
	$(call echo_info,"Compiling test_syntax_tree...")
	$(CC) $(CFLAGS) -o test/test_syntax_tree test/test_syntax_tree.c syntax_tree.c lib/CuTest.c
	$(call echo_success,"Done.")
	$(call echo_info,"Running test_syntax_tree...")
	./test/test_syntax_tree
	$(call echo_info,"Cleaning test_syntax_tree...")
	rm ./test/test_syntax_tree
	$(call echo_success,"Done.")

# 删除所有生成的文件
clean:
	$(call echo_info,"Cleaning C--parser...")
	rm -f C--parser C--parser-debug C--lexical.yy.c C--syntax.tab.c C--syntax.tab.h C--syntax.output
	$(call echo_info,"Cleaning examples...")
	cd examples && rm -f \
		calc calc.yy.c calc.tab.c calc.tab.h \
		count count.yy.c count.tab.c count.tab.h
	$(call echo_success,"Done.")
