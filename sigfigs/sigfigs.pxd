
cimport libc.math as cymath

cpdef make(value)

cdef class SigFig:
    cdef readonly double raw_value
    cdef readonly unsigned int sig_figs

    cpdef get(SigFig self)

