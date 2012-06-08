# USE_LLVM_EXECUTIONENGINE is not fully implemented. We use libbcc instead.
USE_LLVM_EXECUTIONENGINE := false
# If using lib${LLVM_VER}LLVMExecutionEngine,
# need to add files to several Android.mk in external/llvm, and comment out some stuff in
# llvm DynamicLibrary.cpp and Intercept.cpp

DEBUG_BUILD := false

LOCAL_PATH := $(call my-dir)
LLVM_ROOT_PATH := $(call get_llvm_root_path)
LLVM_VER :=
ifeq ($(BOARD_USE_QCOM_LLVM_CLANG_RS),true)
	LLVM_VER := RS
endif
# These are for using llvm::ExecutionEngine, also remove libbcc
# lib${LLVM_VER}LLVMX86CodeGen;lib${LLVM_VER}LLVMX86Info;lib${LLVM_VER}LLVMBitReader;lib${LLVM_VER}LLVMSelectionDAG;lib${LLVM_VER}LLVMAsmPrinter;lib${LLVM_VER}LLVMJIT;lib${LLVM_VER}LLVMCodeGen;lib${LLVM_VER}LLVMTarget;lib${LLVM_VER}LLVMMC;lib${LLVM_VER}LLVMScalarOpts;lib${LLVM_VER}LLVMipo;lib${LLVM_VER}LLVMTransformUtils;lib${LLVM_VER}LLVMCore;lib${LLVM_VER}LLVMSupport;lib${LLVM_VER}LLVMSystem;lib${LLVM_VER}LLVMAnalysis;lib${LLVM_VER}LLVMInstCombine;lib${LLVM_VER}LLVMipa;lib${LLVM_VER}LLVMMCParser;lib${LLVM_VER}LLVMExecutionEngine;
libMesa_STATIC_LIBS :=  \
    lib${LLVM_VER}LLVMBitReader    \
    lib${LLVM_VER}LLVMSelectionDAG \
    lib${LLVM_VER}LLVMAsmPrinter   \
    lib${LLVM_VER}LLVMJIT          \
    lib${LLVM_VER}LLVMCodeGen      \
    lib${LLVM_VER}LLVMTarget       \
    lib${LLVM_VER}LLVMMC           \
    lib${LLVM_VER}LLVMScalarOpts   \
    lib${LLVM_VER}LLVMipo          \
    lib${LLVM_VER}LLVMTransformUtils \
    lib${LLVM_VER}LLVMCore         \
    lib${LLVM_VER}LLVMSupport      \
    lib${LLVM_VER}LLVMSystem       \
    lib${LLVM_VER}LLVMAnalysis     \
    lib${LLVM_VER}LLVMInstCombine  \
    lib${LLVM_VER}LLVMipa          \
    lib${LLVM_VER}LLVMMCParser     \
    lib${LLVM_VER}LLVMExecutionEngine

libMesa_SRC_FILES := \
    src/glsl/glcpp/pp.c \
    src/glsl/glcpp/glcpp-lex.c \
    src/glsl/glcpp/glcpp-parse.c \
    src/glsl/ast_expr.cpp \
    src/glsl/ast_function.cpp \
    src/glsl/ast_to_hir.cpp \
    src/glsl/ast_type.cpp \
    src/glsl/builtin_function.cpp \
    src/glsl/glsl_lexer.cpp \
    src/glsl/glsl_parser.cpp \
    src/glsl/glsl_parser_extras.cpp \
    src/glsl/glsl_symbol_table.cpp \
    src/glsl/glsl_types.cpp \
    src/glsl/hir_field_selection.cpp \
    src/glsl/ir.cpp \
    src/glsl/ir_basic_block.cpp \
    src/glsl/ir_clone.cpp \
    src/glsl/ir_constant_expression.cpp \
    src/glsl/ir_expression_flattening.cpp \
    src/glsl/ir_function.cpp \
    src/glsl/ir_function_can_inline.cpp \
    src/glsl/ir_hierarchical_visitor.cpp \
    src/glsl/ir_hv_accept.cpp \
    src/glsl/ir_import_prototypes.cpp \
    src/glsl/ir_print_visitor.cpp \
    src/glsl/ir_reader.cpp \
    src/glsl/ir_rvalue_visitor.cpp \
    src/glsl/ir_set_program_inouts.cpp \
    src/glsl/ir_validate.cpp \
    src/glsl/ir_variable.cpp \
    src/glsl/ir_variable_refcount.cpp \
    src/glsl/link_functions.cpp \
    src/glsl/linker.cpp \
    src/glsl/loop_analysis.cpp \
    src/glsl/loop_controls.cpp \
    src/glsl/loop_unroll.cpp \
    src/glsl/lower_discard.cpp \
    src/glsl/lower_if_to_cond_assign.cpp \
    src/glsl/lower_instructions.cpp \
    src/glsl/lower_jumps.cpp \
    src/glsl/lower_mat_op_to_vec.cpp \
    src/glsl/lower_noise.cpp \
    src/glsl/lower_texture_projection.cpp \
    src/glsl/lower_variable_index_to_cond_assign.cpp \
    src/glsl/lower_vec_index_to_cond_assign.cpp \
    src/glsl/lower_vec_index_to_swizzle.cpp \
    src/glsl/lower_vector.cpp \
    src/glsl/main.cpp \
    src/glsl/opt_algebraic.cpp \
    src/glsl/opt_constant_folding.cpp \
    src/glsl/opt_constant_propagation.cpp \
    src/glsl/opt_constant_variable.cpp \
    src/glsl/opt_copy_propagation.cpp \
    src/glsl/opt_dead_code.cpp \
    src/glsl/opt_dead_code_local.cpp \
    src/glsl/opt_dead_functions.cpp \
    src/glsl/opt_discard_simplification.cpp \
    src/glsl/opt_function_inlining.cpp \
    src/glsl/opt_if_simplification.cpp \
    src/glsl/opt_noop_swizzle.cpp \
    src/glsl/opt_redundant_jumps.cpp \
    src/glsl/opt_structure_splitting.cpp \
    src/glsl/opt_swizzle_swizzle.cpp \
    src/glsl/opt_tree_grafting.cpp \
    src/glsl/s_expression.cpp \
    src/glsl/strtod.c \
    src/glsl/ir_to_llvm.cpp \
    src/mesa/main/shaderobj.c \
    src/mesa/program/hash_table.c \
    src/mesa/program/prog_parameter.cpp \
    src/mesa/program/symbol_table.c \
    src/pixelflinger2/buffer.cpp \
    src/pixelflinger2/format.cpp \
    src/pixelflinger2/llvm_scanline.cpp \
    src/pixelflinger2/llvm_texture.cpp \
    src/pixelflinger2/pixelflinger2.cpp \
    src/pixelflinger2/raster.cpp \
    src/pixelflinger2/scanline.cpp \
    src/pixelflinger2/shader.cpp \
    src/pixelflinger2/texture.cpp \
    src/talloc/hieralloc.c

libMesa_C_INCLUDES := \
    $(LOCAL_PATH) \
    $(LOCAL_PATH)/src/glsl   \
    $(LOCAL_PATH)/src/mesa   \
    $(LOCAL_PATH)/src/talloc \
    $(LOCAL_PATH)/src/mapi   \
    $(LOCAL_PATH)/include    \
    frameworks/compile/libbcc/include

# Static library for host
# ========================================================
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional

ifeq ($(DEBUG_BUILD),true)
LOCAL_CFLAGS += -DDEBUG -UNDEBUG -O0 -g
else
LOCAL_CFLAGS += -O3
endif

LOCAL_MODULE := libMesa
LOCAL_SRC_FILES := $(libMesa_SRC_FILES)

ifeq ($(USE_LLVM_EXECUTIONENGINE),true)
LOCAL_CFLAGS += -DUSE_LLVM_EXECUTIONENGINE=1
LOCAL_STATIC_LIBRARIES := lib${LLVM_VER}LLVMX86CodeGen lib${LLVM_VER}LLVMX86Info $(libMesa_STATIC_LIBS)
else
LOCAL_CFLAGS += -DUSE_LLVM_EXECUTIONENGINE=0
LOCAL_SHARED_LIBRARIES := libbcc
endif

LOCAL_C_INCLUDES := $(libMesa_C_INCLUDES)

include $(LLVM_ROOT_PATH)/llvm-host-build.mk
include $(BUILD_HOST_STATIC_LIBRARY)


# Static library for target
# ========================================================
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional

ifeq ($(DEBUG_BUILD),true)
LOCAL_CFLAGS += -DDEBUG -UNDEBUG -O0 -g
else
LOCAL_CFLAGS += -O3
endif

LOCAL_MODULE := libMesa
LOCAL_SRC_FILES := $(libMesa_SRC_FILES)
LOCAL_SHARED_LIBRARIES := libstlport libcutils libdl libutils

ifeq ($(USE_LLVM_EXECUTIONENGINE),true)
LOCAL_CFLAGS += -DUSE_LLVM_EXECUTIONENGINE=1
LOCAL_STATIC_LIBRARIES :=  lib${LLVM_VER}LLVMARMCodeGen lib${LLVM_VER}LLVMARMInfo lib${LLVM_VER}LLVMARMDisassembler \
    lib${LLVM_VER}LLVMARMAsmPrinter $(libMesa_STATIC_LIBS)
else
LOCAL_CFLAGS += -DUSE_LLVM_EXECUTIONENGINE=0
LOCAL_SHARED_LIBRARIES += libbcc
endif

LOCAL_C_INCLUDES := $(libMesa_C_INCLUDES)

include $(LLVM_ROOT_PATH)/llvm-device-build.mk
include $(BUILD_STATIC_LIBRARY)

# glsl_compiler for host
# ========================================================
include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := optional

ifeq ($(DEBUG_BUILD),true)
LOCAL_CFLAGS += -DDEBUG -UNDEBUG -O0 -g
endif

LOCAL_MODULE := glsl_compiler
LOCAL_SRC_FILES := src/glsl/glsl_compiler.cpp
LOCAL_C_INCLUDES := $(libMesa_C_INCLUDES)
LOCAL_STATIC_LIBRARIES := libMesa

include $(BUILD_HOST_EXECUTABLE)

# Build children
# ========================================================
include $(call all-makefiles-under,$(LOCAL_PATH))
