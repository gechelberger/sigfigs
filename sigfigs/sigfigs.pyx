cimport libc.math as cymath
cimport libc.stdlib as stdlib

cpdef make(value):
    cdef char* str_value = value
    cdef double raw_value = stdlib.strtod(str_value, NULL)

    cdef int counter = 0
    cdef int zero_counter = 0
    cdef bint decimal = False
    cdef char digit
    for c in str_value:
        if c == '0':
            zero_counter += 1
        elif c == '.':
            decimal = True
        elif c > '0' and c <= '9':
            if counter > 0:
                counter += zero_counter
            zero_counter = 0
            counter += 1

    if decimal:
        counter += zero_counter


    return SigFig.__new__(SigFig, raw_value, counter)

cdef class SigFig:


    @property
    def most_significant_digit(SigFig self):
        return cymath.floor(cymath.log10(self.raw_value))

    @property
    def least_significant_digit(SigFig self):
        return self.most_significant_digit - self.sig_figs

    def __cinit__(SigFig self, double value, unsigned int sig_figs):
        self.raw_value = value
        self.sig_figs = sig_figs

    def __add__(a, b):
        is_a_sigfig = isinstance(a, SigFig)
        is_b_sigfig = isinstance(b, SigFig)
        if is_a_sigfig and is_b_sigfig:
            msb = max(a.most_significant_digit, b.most_significant_digit)
            lsb = max(a.least_significant_digit, b.least_significant_digit)
            return SigFig.__new__(SigFig, a.raw_value + b.raw_value, msb - lsb)
        elif is_a_sigfig:
            return SigFig.__new__(SigFig, a.raw_value + b, a.sig_figs)
        else:
            return SigFig.__new__(SigFig, a + b.raw_value, b.sig_figs)

    __iadd__ = __add__

    def __sub__(a, b):
        is_a_sigfig = isinstance(a, SigFig)
        is_b_sigfig = isinstance(b, SigFig)
        if is_a_sigfig and is_b_sigfig:
            msb = max(a.most_significant_digit, b.most_significant_digit)
            lsb = max(a.least_significant_digit, b.least_significant_digit)
            return SigFig.__new__(SigFig, a.raw_value - b.raw_value, msb - lsb)
        elif is_a_sigfig:
            return SigFig.__new__(SigFig, a.raw_value - b, a.sig_figs)
        else:
            return SigFig.__new__(SigFig, a - b.raw_value, b.sig_figs)

    __isub__ = __sub__

    def __mul__(a, b):
        is_a_sigfig = isinstance(a, SigFig)
        is_b_sigfig = isinstance(b, SigFig)
        if is_a_sigfig and is_b_sigfig:
            return SigFig.__new__(SigFig, a.raw_value * b.raw_value, min(a.sig_figs, b.sig_figs))
        elif is_a_sigfig:
            return SigFig.__new__(SigFig, a.raw_value * b, a.sig_figs)
        else:
            return SigFig.__new__(SigFig, a * b.raw_value, b.sig_figs)

    __imul__ = __mul__

    def __truediv__(a, b):
        is_a_sigfig = isinstance(a, SigFig)
        is_b_sigfig = isinstance(b, SigFig)
        if is_a_sigfig and is_b_sigfig:
            return SigFig.__new__(SigFig, a.raw_value / b.raw_value, min(a.sig_figs, b.sig_figs))
        elif is_a_sigfig:
            return SigFig.__new__(SigFig, a.raw_value / b, a.sig_figs)
        else:
            return SigFig.__new__(SigFig, a / b.raw_value, b.sig_figs)

    __itruediv__ = __truediv__

    def __pow__(self, power, modulo):
        pass

    def __neg__(SigFig self):
        return SigFig.__new__(SigFig, -self.raw_value, self.sig_figs)

    def __pos__(SigFig self):
        return self

    def __float__(SigFig self):
        return self.get()

    def __floordiv__(a, b):
        cdef SigFig ret = a / b
        ret.raw_value = cymath.floor(ret.raw_value)
        return ret

    cpdef get(SigFig self):
        cdef double value = self.raw_value
        cdef int lsd = self.least_significant_digit
        cdef double scale = cymath.pow(10, lsd+1)
        value = cymath.round(value / scale)
        return value * scale

