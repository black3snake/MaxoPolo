using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp2
{
    internal class Program
    {
        /*
            Программа Первая:)
         */
        static void Main(string[] args) // Этот метод называется "Main" (Обязательно !)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.BackgroundColor = ConsoleColor.White;
            Console.BackgroundColor = ConsoleColor.White;

            // UNDONE: Доработать код
            Console.WriteLine("Hello world");

            // TODO: Добавить новую функциональность

            Console.ResetColor();
            Console.Write("Goodbye");

            // HACK: Этот код, временное решение
            Console.ReadKey();
        }
    }
}
