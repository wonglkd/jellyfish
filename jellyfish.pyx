from libc.stdlib cimport *

cdef extern from "ctype.h":
    int toupper(int)

cdef extern from "stdlib.h":
    void *memset(void *str, int c, size_t n)

cdef char upper_char(char c):
    return <char>toupper(<int>c)

def soundex(s):
    cdef short uni = False
    if isinstance(s, unicode):
        s = s.encode('ASCII')
        uni = True

    cdef:
        char* word = s
        Py_ssize_t word_len = len(s)
        char result[5]

    if word_len == 0:
        return "0000"

    result[0] = upper_char(word[0])
    result[1] = '0'
    result[2] = '0'
    result[3] = '0'
    result[4] = 0

    cdef:
        char code
        char last_code = '0'
        Py_ssize_t length = 1
        Py_ssize_t loops = 0
        char c

    for c in word[:word_len]:
        c = upper_char(c)
        loops += 1

        if c in [66, 70, 80, 86]:
            code = '1'
        elif c in [67, 71, 74, 75, 81, 83, 88, 90]:
            code = '2'
        elif c in [68, 84]:
            code = '3'
        elif c == 76:
            code = '4'
        elif c in [77, 78]:
            code = '5'
        elif c == 82:
            code = '6'
        elif c in [72, 87]:
            continue
        else:
            last_code = '0'
            continue

        if code == last_code:
            continue

        last_code = code

        if loops > 1:
            result[length] = code
            length += 1

        if length == 4:
            break

    if uni:
        # Return unicode if that was what we were passed in
        return result[:4].decode('ASCII')

    return result


def metaphone(s):
    s = s.upper()

    cdef short uni = False
    if isinstance(s, unicode):
        s = s.encode('ASCII')
        uni = True

    cdef:
        char* word = s
        Py_ssize_t word_len = len(s)

        char* result = <char*>calloc(word_len * 2 + 1, sizeof(char))
        char* r

        char c, _next
        char temp = 0

        Py_ssize_t sp = 0
        Py_ssize_t sp2 = 0
        Py_ssize_t rp = 0

        object str_result
        unicode uni_result

    c = word[0]
    if c:
        _next = word[1]

        if ((c == 'K' and _next == 'N') or
            (c == 'G' and _next == 'N') or
            (c == 'P' and _next == 'N') or
            (c == 'A' and _next == 'C') or
            (c == 'W' and _next == 'R') or
            (c == 'A' and _next == 'E')):

            sp += 1

    _next = word[sp]
    sp2 = sp - 1
    rp = 0
    while sp2 < word_len:
        sp2 += 1
        c = _next
        _next = word[sp2 + 1]

        if c == _next and c != 'C':
            continue

        if c in [65, 69, 73, 79, 85]:  # AEIOU
            if sp2 == sp or word[sp2 - 1] == ' ':
                result[rp] = c;
                rp += 1
        elif c == 'B':
            if (not (sp2 > sp and word[sp2 - 1] == 'M')) or _next:
                result[rp] = 'B'
                rp += 1
        elif c == 'C':
            if (_next == 'I' and word[sp2 + 2] == 'A') or _next == 'H':
                result[rp] = 'X'
                rp += 1

                _next = word[sp2 + 2]
                sp2 += 1
            elif _next == 'I' or _next == 'E' or _next == 'Y':
                result[rp] = 'S'
                rp += 1

                _next = word[sp2 + 2]
                sp2 += 1
            else:
                result[rp] = 'K'
                rp += 1
        elif c == 'D':
            temp = word[sp2 + 2]
            if _next == 'G' and (temp == 'E' or temp == 'Y' or temp == 'I'):
                result[rp] = 'J'
                rp += 1

                sp2 += 2
                next = word[sp2 + 1]
            else:
                result[rp] = 'T'
                rp += 1
        elif c == 'F':
            result[rp] = 'F'
            rp += 1
        elif c == 'G':
            if _next == 'I' or _next == 'E' or _next == 'Y':
                result[rp] = 'J'
                rp += 1
            elif _next != 'H' and _next != 'N':
                result[rp] = 'K'
                rp += 1
            elif _next == 'H':
                temp = word[sp2 + 2]
                if temp in [65, 69, 73, 79, 85]:
                    sp2 += 1
                    _next = word[sp2 + 1]
            elif _next != 'N':
                result[rp] = 'K'
                rp += 1
        elif c == 'H':
            if sp2 == sp or _next in [65, 69, 73, 79, 85]:
                result[rp] = 'H'
                rp += 1
            else:
                # We don't roll this into the above if because we can't
                # grab temp until we know sp2 != sp (sp may be 0)
                temp = word[sp2 - 1]
                if temp in [65, 69, 73, 79, 85]:
                    result[rp] = 'H'
                    rp += 1
        elif c == 'J':
            result[rp] = 'J'
            rp += 1
        elif c == 'K':
            if sp2 == sp or word[sp2 - 1] != 'C':
                result[rp] = 'K'
                rp += 1
        elif c == 'L':
            result[rp] = 'L'
            rp += 1
        elif c == 'M':
            result[rp] = 'M'
            rp += 1
        elif c == 'N':
            result[rp] = 'N'
            rp += 1
        elif c == 'P':
            result[rp] = 'F'
            rp += 1

            if _next == 'H':
                _next = word[sp2 + 2]
                sp2 += 1
        elif c == 'Q':
            result[rp] = 'K'
            rp += 1
        elif c == 'R':
            result[rp] = 'R'
            rp += 1
        elif c == 'S':
            if _next == 'H':
                result[rp] = 'X'
                rp += 1

                _next = word[sp2 + 2]
                sp2 += 1
            elif _next == 'I':
                temp = word[sp2 + 2]
                if temp == 'O' or temp == 'A':
                    result[rp] = 'X'
                    rp += 1
                    sp2 += 2
                    _next = word[sp2 + 1]
            else:
                result[rp] = 'S'
                rp += 1
        elif c == 'T':
            temp = word[sp2 + 2]
            if _next == 'I' and (temp == 'A' or temp == 'O'):
                result[rp] = 'X'
                rp += 1
            elif _next == 'H':
                result[rp] = '0'
                rp += 1

                _next = word[sp2 + 2]
                sp2 += 1
            elif _next != 'C' or temp != 'H':
                result[rp] = 'T'
                rp += 1
        elif c == 'V':
            result[rp] = 'F'
            rp += 1
        elif c == 'W':
            if sp2 == sp and _next == 'H':
                _next = word[sp2 + 2]
                sp2 += 1

            if _next in [65, 69, 73, 79, 85]:
                result[rp] = 'W'
                rp += 1
        elif c == 'X':
            if sp2 == sp:
                if _next == 'H':
                    result[rp] = 'X'
                elif _next == 'I':
                    temp = word[sp2 + 2]
                    if temp == 'O' or temp == 'A':
                        result[rp] = 'X'
                        rp += 1
                    else:
                        result[rp] = 'S'
                        rp += 1
                else:
                    result[rp] = 'S'
                    rp += 1
            else:
                result[rp] = 'K'
                result[rp + 1] = 'S'
                rp += 2
        elif c == 'Y':
            if _next in [65, 69, 73, 79, 85]:
                result[rp] = 'Y'
                rp += 1
        elif c == 'Z':
            result[rp] = 'S'
            rp += 1
        elif c == ' ':
            if result[rp] != ' ':
                result[rp] = ' '
                rp += 1

    if uni:
        uni_result = result.decode('ASCII')
        free(result)
        return uni_result

    str_result = result
    free(result)
    return str_result


def match_rating_codex(s):
    cdef short uni = False
    if isinstance(s, unicode):
        s = s.encode('ASCII')
        uni = True

    cdef:
        char* word = s
        Py_ssize_t word_len = len(s)
        Py_ssize_t i
        Py_ssize_t j = 0
        char c
        char prev = 0

        char codex[7]

    for i in range(0, word_len):
        if j >= 7:
            break

        c = upper_char(word[i])

        if c == ' ':
            continue
        elif c in [65, 69, 73, 79, 85]:
            if i != 0:
                continue

        if c == prev:
            continue

        if j == 6:
            codex[3] = codex[4]
            codex[4] = codex[5]
            j = 5

        codex[j] = c
        j += 1

    codex[j] = 0

    if uni:
        return codex.decode('ASCII')
    return codex


def match_rating_comparison(s1, s2):
    s1_codex_py = match_rating_codex(s1)
    if not s1_codex_py:
        return -1

    s2_codex_py = match_rating_codex(s2)
    if not s2_codex_py:
        return -1

    cdef:
        char* s1_codex = s1_codex_py
        char* s2_codex = s2_codex_py
        char* longer

        char c

        Py_ssize_t s1c_len = len(s1_codex)
        Py_ssize_t s2c_len = len(s2_codex)

        Py_ssize_t i, j, diff

    if abs(s1c_len - s2c_len) >= 3:
        return -1

    for i in range(0, _min(s1c_len, s2c_len)):
        if s1_codex[i] == s2_codex[i]:
            s1_codex[i] = ' '
            s2_codex[i] = ' '

    i = s1c_len - 1
    j = s2c_len - 1
    while i != 0 and j != 0:
        if s1_codex[i] == ' ':
            i -= 1
            continue

        if s2_codex[j] == ' ':
            j -= 1
            continue

        if s1_codex[i] == s2_codex[j]:
            s1_codex[i] = ' '
            s2_codex[j] = ' '

        i -= 1
        j -= 1

    if s1c_len > s2c_len:
        longer = s1_codex
    else:
        longer = s2_codex

    diff = 0
    for c in longer:
        if c != ' ':
            diff += 1

    diff = 6 - diff

    i = s1c_len + s2c_len
    if i <= 4:
        return diff >= 5
    elif i <= 7:
        return diff >= 4
    elif i <= 11:
        return diff >= 3

    return diff >= 2


cdef unicode tounicode(char *s):
    return s.decode('UTF-8', 'strict')

cdef inline unsigned _min(unsigned a, unsigned b):
    return a if a <= b else b

def levenshtein_distance(s1, s2):
    if not isinstance(s1, unicode):
        s1 = tounicode(s1)
    if not isinstance(s2, unicode):
        s2 = tounicode(s2)

    return _levenshtein_distance(s1, s2)

cdef unsigned _levenshtein_distance(unicode s1, unicode s2):
    cdef:
        Py_ssize_t s1_len = len(s1)
        Py_ssize_t s2_len = len(s2)
        Py_ssize_t rows = s1_len + 1
        Py_ssize_t cols = s2_len + 1
        Py_ssize_t i, j

        unsigned result, d1, d2, d3

        unsigned* dist = <unsigned*>malloc(rows * cols * sizeof(unsigned))


    for i in range(0, rows):
        dist[i * cols] = i

    for j in range(0, cols):
        dist[j] = j

    for j in range(1, cols):
        for i in range(1, rows):
            if s1[i - 1] == s2[j - 1]:
                dist[(i * cols) + j] = dist[((i - 1) * cols) + (j - 1)]
            else:
                d1 = dist[((i - 1) * cols) + j] + 1;
                d2 = dist[(i * cols) + (j - 1)] + 1;
                d3 = dist[((i - 1) * cols) + (j - 1)] + 1;

                dist[(i * cols) + j] = _min(d1, _min(d2, d3));

    result = dist[(cols * rows) - 1]

    free(dist)

    return result

def damerau_levenshtein_distance(s1, s2):
    if not isinstance(s1, unicode):
        s1 = tounicode(s1)
    if not isinstance(s2, unicode):
        s2 = tounicode(s2)

    return _damerau_levenshtein_distance(s1, s2)

cdef unsigned _damerau_levenshtein_distance(unicode s1, unicode s2):
    cdef:
        Py_ssize_t s1_len = len(s1)
        Py_ssize_t s2_len = len(s2)
        Py_ssize_t rows = s1_len + 1
        Py_ssize_t cols = s2_len + 1

        unsigned i, j
        unsigned d1, d2, d3, d_now
        unsigned cost

        unsigned *dist = <unsigned*>malloc(rows * cols * sizeof(unsigned))

        Py_UNICODE s1_prev, s2_prev

    for i in range(0, rows):
        dist[i * cols] = i

    for j in range(0, cols):
        dist[j] = j

    for i in range(1, rows):
        for j in range(1, cols):
            s1_prev = s1[i - 1]
            s2_prev = s2[j - 1]

            cost = s1_prev == s2_prev

            d1 = dist[((i - 1) * cols) + j] + 1;
            d2 = dist[(i * cols) + (j - 1)] + 1;
            d3 = dist[((i - 1) * cols) + (j - 1)] + cost;

            d_now = _min(d1, _min(d2, d3));

            if (i > 2 and j > 2 and s1_prev == s2[j - 2] and
                s1[i - 2] == s2_prev):

                d1 = dist[((i - 2) * cols) + (j - 2)] + cost;
                d_now = _min(d_now, d1);

            dist[(i * cols) + j] = d_now;

    d_now = dist[(cols * rows) - 1]
    free(dist)

    return d_now

cdef inline int _notnum(char c):
    if c > 57 or c < 48:
        return True
    return False

cdef double _jaro_winkler(unicode ying, unicode yang, int long_tolerance,
                          int winklerize):
    cdef:
        char* flags

        double weight

        Py_ssize_t ying_length, yang_length, min_length
        Py_ssize_t search_range
        Py_ssize_t lowlim, hilim
        Py_ssize_t trans_count, common_chars

        Py_ssize_t i, j, k

    ying_length = len(ying)
    yang_length = len(yang)

    if ying_length == 0 or yang_length == 0:
        return 0.0

    if ying_length > yang_length:
        search_range = ying_length
        min_length = yang_length
    else:
        search_range = yang_length
        min_length = ying_length

    flags = <char*>calloc(ying_length + yang_length, sizeof(char))

    search_range = (search_range / 2) - 1
    if search_range < 0:
        search_range = 0

    # Looking only within the search range, count and flag the matched pairs
    common_chars = 0
    for i in range(0, ying_length):
        if i >= search_range:
            lowlim = i - search_range
        else:
            lowlim = 0

        if (i + search_range) <= (yang_length - 1):
            hilim = i + search_range
        else:
            hilim = yang_length - 1

        for j in range(lowlim, hilim + 1):
            if flags[ying_length + j] != '1' and yang[j] == ying[i]:
                flags[ying_length + j] = '1'
                flags[i] = '1'
                common_chars += 1
                break

    # If no characters in common - return
    if common_chars == 0:
        free(flags)
        return 0.0

    # Count the number of transpositions
    k = 0
    trans_count = 0
    for i in range(0, ying_length):
        if flags[i] == '1':
            for j in range(k, yang_length):
                if flags[ying_length + j] == '1':
                    k = j + 1
                    break

            if ying[i] != yang[j]:
                trans_count += 1

    trans_count = trans_count / 2

    # adjust for similarities in nonmatched characters

    # Main weight computation.
    weight = ((common_chars / <double>ying_length) +
              (common_chars / <double>yang_length) +
              (<double>(common_chars - trans_count) / <double>common_chars))
    weight = weight / 3

    # Continue to boost the weight if the strings are similar
    if winklerize and weight > 0.7:
        # Adjust for having up to the first 4 characters in common
        if min_length >= 4:
            j = 4
        else:
            j = min_length

        i = 0
        while i < j and ying[i] == yang[i] and _notnum(ying[i]):
            i += 1

        if i:
            weight += i * 0.1 * (1.0 - weight)


        # Optionally adjust for long strings. */
        # After agreeing beginning chars, at least two more must agree and
        # the agreeing characters must be > .5 of remaining characters.
        if (long_tolerance and min_length > 4 and common_chars > (i + 1) and
            (2 * common_chars) >= (min_length + i)):

            if _notnum(ying[0]):
                weight += (<double>(1.0 - weight) *
                           (<double>(common_chars - i - 1) /
                            <double>(ying_length + yang_length - i * 2 + 2)))

    free(flags)

    return weight

def jaro_winkler(ying, yang):
    if not isinstance(ying, unicode):
        ying = tounicode(ying)
    if not isinstance(yang, unicode):
        yang = tounicode(yang)

    return _jaro_winkler(ying, yang, False, True)

def jaro_distance(ying, yang):
    if not isinstance(ying, unicode):
        ying = tounicode(ying)
    if not isinstance(yang, unicode):
        yang = tounicode(yang)

    return _jaro_winkler(ying, yang, False, False)
