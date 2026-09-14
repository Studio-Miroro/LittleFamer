
#* Небольшой вспомагательный python-скрипт
#* ---------------------------------------
#* format - Форматирует .gd файлы
#* linter - Проверяет синтаксические ошибки
#* clear  - Очищает временные Godot
#* ---------------------------------------

from helper.format  import format
from helper.linter  import linter
from helper.clear   import clear

def help() -> None:
    print("---- Project Helper ----")
    print("\t1. format\t - Formatting GDscript files")
    print("\t2. linter\t - Liting GDscript files")
    print("\t3. clear\t - Clering trash")
    print("\t0. (e)xit\t - Exit")

def main() -> None:
    while 1:
        help()
        command = input("Select the command: ")
        print() # Разделитель
        match command:
            case "1" | "format": format()
            case "2" | "linter": linter()
            case "3" | "clear" : clear()
            case "0" | "exit" | "e": break
            case _: print("Error: Unknown command")

if __name__ == "__main__":
    main()