/* Build scaffolding only; no production behavior or audio correctness claim. */
#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L
#error "The scaffold requires C11 or later"
#endif

_Static_assert(sizeof(char) == 1, "C object model sanity check");

int main(void)
{
    return 0;
}
