#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import, division, print_function

r"""PyFMT Main Module

    DEV STATUS
    ----------
    This file only exists to provide a simple call function to fmtparams.py.
    It may not function properly in all cases do to the fact ftmparams.py is
    called at the root widget level as opposed to root = Toplevel().
"""

import os
import sys
import tkinter
from tkinter import *
import tkinter.messagebox
from builtins import input
import subprocess

#--------------------------------------------------------------- Pause function
def pause():
    """Pause Statement

    Actions Performed:
        1. Prompt the user for input to create a pause"""
    input("\nPress [ ENTER ] to continue...")

#------------------------------------------------------------------------- done
def done():
    """Exit messagebox window"""
    root.quit()

#---------------------------------------------------------------------- MsgWarn
def MsgUdev():
    root = Tk()
    root.withdraw()
    tkinter.messagebox.showinfo("Under Development", "Feature is under development")

#----------------------------------------------------------------- clear_screen
def clear_screen():
    """Clear Screen Based On Platform Type"""
    if sys.platform == 'wi32':
        os.system('cls')
    else:
        os.system('clear')

#---------------------------------------------------------- Main Menu Functions
def main():
    """Main Menu Functions

    Function Notes:
        * Setup Station Parameters
        * Tests CAT control via Hamlib
        * Writes fmtparams.ini and fmt.ini

    All other functions are under development

    """
    clear_screen()
    while True:
        main_menu()
        selection = input("Selection: ")
        # Set Station Parameters and Rig Control
        if selection == '1':
            subprocess.call(['python', 'fmtparams.py'])
            main()
        # Ris Calibration Functions
        if selection == '2':
            MsgUdev()
            main()
        # ARRL FM Test Functions
        if selection == '3':
            t='Ths feature is under development'
            MsgUdev()
            main()
        # exit basic menu
        if selection == '4':
            sys.exit("\n")
        else:
            return

#-------------------------------------------------------------------- Main Menu
def main_menu():
    """Prints The Main Menu"""
    print(45 * "-")
    print(" PyFMT Main Menu")
    print(45 * "-")
    print("\n Station Parameters")
    print("   1. Set Station Parameters and Rig Control")
    print("\n Rig Calibration")
    print("   2. Setup Test Stations")
    print("\n ARRL  Frequency Measuring")
    print("   3. Setup ARRL Run Stations")
    print("\n Utilities")
    print("   4. Exit")
    print("")

if __name__ == "__main__":
    main()
