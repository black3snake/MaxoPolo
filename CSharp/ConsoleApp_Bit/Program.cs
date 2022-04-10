using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp_Bit
{
    internal class Program
    {
        static void Main(string[] args)
        {
            int a = 1;
            int b = ~a;
            int c = b + 1;
            Console.WriteLine($"a = {a}, b = {b}, c = {c}");

            #region Тестовый вариант
            Console.WriteLine($"a = {a}, b = {b}, c = {c}");
            Console.WriteLine($"a = {a}, b = {b}, c = {c}");
            #endregion

            //Delay
            Console.ReadKey();

            
        }
    }
}
