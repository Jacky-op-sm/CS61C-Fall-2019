

int main()
{
    ComplexNumber *p = newComplexNumber(1, 0);
    int i = MandelbrotIterations(100, p, 2);
    printf("%d\n", i);
}