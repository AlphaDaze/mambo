#ifdef PLUGINS_NEW

#include <stdio.h>
#include <assert.h>
#include <inttypes.h>
#include "../plugins.h"


const char *a64_insts[] = {"A64_CBZ_CBNZ",
                  "A64_B_COND",
                  "A64_SVC",
                  "A64_HVC",
                  "A64_SMC",
                  "A64_BRK",
                  "A64_HLT",
                  "A64_DCPS1",
                  "A64_DCPS2",
                  "A64_DCPS3",
                  "A64_MSR_IMMED",
                  "A64_HINT",
                  "A64_CLREX",
                  "A64_DSB",
                  "A64_DMB",
                  "A64_ISB",
                  "A64_SYS",
                  "A64_MRS_MSR_REG",
                  "A64_SYSL",
                  "A64_TBZ_TBNZ",
                  "A64_B_BL",
                  "A64_BR",
                  "A64_BLR",
                  "A64_RET",
                  "A64_ERET",
                  "A64_DRPS",
                  "A64_LDX_STX",
                  "A64_LDR_LIT",
                  "A64_LDP_STP",
                  "A64_LDR_STR_IMMED",
                  "A64_LDR_STR_REG",
                  "A64_LDR_STR_UNSIGNED_IMMED",
                  "A64_LDX_STX_MULTIPLE",
                  "A64_LDX_STX_MULTIPLE_POST",
                  "A64_LDX_STX_SINGLE",
                  "A64_LDX_STX_SINGLE_POST",
                  "A64_LDADD",
                  "A64_LDCLR",
                  "A64_LDEOR",
                  "A64_LDSMAX",
                  "A64_LDSMIN",
                  "A64_LDUMAX",
                  "A64_LDUMIN",
                  "A64_LDSET",
                  "A64_SWP",
                  "A64_ADD_SUB_IMMED",
                  "A64_BFM",
                  "A64_EXTR",
                  "A64_LOGICAL_IMMED",
                  "A64_MOV_WIDE",
                  "A64_ADR",
                  "A64_ADD_SUB_EXT_REG",
                  "A64_ADD_SUB_SHIFT_REG",
                  "A64_ADC_SBC",
                  "A64_CCMP_CCMN_IMMED",
                  "A64_CCMP_CCMN_REG",
                  "A64_COND_SELECT",
                  "A64_DATA_PROC_REG1",
                  "A64_DATA_PROC_REG2",
                  "A64_DATA_PROC_REG3",
                  "A64_L fprintf(stderr, "%s\n", a64_insts[ctx->code.inst])OGICAL_REG",
                  "A64_SIMD_ACROSS_LANE",
                  "A64_SIMD_COPY",
                  "A64_SIMD_EXTRACT",
                  "A64_SIMD_MODIFIED_IMMED",
                  "A64_SIMD_PERMUTE",
                  "A64_SIMD_SCALAR_COPY",
                  "A64_SIMD_SCALAR_PAIRWISE",
                  "A64_SIMD_SCALAR_SHIFT_IMMED",
                  "A64_SIMD_SCALAR_THREE_DIFF",
                  "A64_SIMD_SCALAR_THREE_SAME",
                  "A64_SIMD_SCALAR_TWO_REG",
                  "A64_SIMD_SCALAR_X_INDEXED",
                  "A64_SIMD_SHIFT_IMMED",
                  "A64_SIMD_TABLE_LOOKUP",
                  "A64_SIMD_THREE_DIFF",
                  "A64_SIMD_THREE_SAME",
                  "A64_SIMD_TWO_REG",
                  "A64_SIMD_X_INDEXED",
                  "A64_CRYPTO_AES",
                  "A64_CRYPTO_SHA_REG3",
                  "A64_CRYPTO_SHA_REG2",
                  "A64_FCMP",
                  "A64_FCCMP",
                  "A64_FCSEL",
                  "A64_FLOAT_REG1",
                  "A64_FLOAT_REG2",
                  "A64_FLOAT_REG3",
                  "A64_FMOV_IMMED",
                  "A64_FLOAT_CVT_FIXED",
                  "A64_FLOAT_CVT_INT",
                  "A64_INVALID"};

int instruction_print_handler(mambo_context *ctx);

__attribute__((constructor)) void print_instr_init_plugin() {
  mambo_context *ctx = mambo_register_plugin();
  assert(ctx != NULL);

  mambo_register_pre_inst_cb(ctx, &instruction_print_handler);
}

int instruction_print_handler(mambo_context *ctx) {
  #ifdef __aarch64__
    fprintf(stderr, "%s\n", a64_insts[ctx->code.inst]);
  #else
    #error Unsupported architecture
  #endif
}

#endif