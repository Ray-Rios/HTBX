#!/usr/bin/env python3
"""
MySQL to PostgreSQL Converter for PEQ Database
Converts MySQL dump syntax to PostgreSQL-compatible SQL
"""

import re
import sys
import os

def convert_mysql_to_postgresql(input_file, output_file):
    print(f"🔄 Converting {input_file} to PostgreSQL format...")
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
        with open(output_file, 'w', encoding='utf-8') as outfile:
            line_count = 0
            converted_lines = 0
            
            # Write PostgreSQL header
            outfile.write("-- Converted PEQ Database for PostgreSQL\n")
            outfile.write("-- Original MySQL dump converted to PostgreSQL syntax\n\n")
            outfile.write("SET client_encoding = 'UTF8';\n")
            outfile.write("SET standard_conforming_strings = on;\n\n")
            
            for line in infile:
                line_count += 1
                original_line = line
                
                # Skip MySQL-specific comments and commands
                if (line.startswith('/*!') or 
                    line.startswith('--') or
                    'SET @' in line or
                    'SET NAMES' in line or
                    'SET character_set_client' in line or
                    'SET FOREIGN_KEY_CHECKS' in line or
                    'SET UNIQUE_CHECKS' in line or
                    'SET SQL_MODE' in line or
                    'SET TIME_ZONE' in line or
                    'SET SQL_NOTES' in line):
                    continue
                
                # Convert CREATE DATABASE
                if 'CREATE DATABASE' in line and 'IF NOT EXISTS' in line:
                    # Skip database creation - we'll use existing Phoenix DB
                    continue
                
                # Convert USE database
                if line.startswith('USE '):
                    continue
                
                # Convert DROP TABLE IF EXISTS
                line = re.sub(r'DROP TABLE IF EXISTS `([^`]+)`;', 
                             r'DROP TABLE IF EXISTS temp_\1 CASCADE;', line)
                
                # Convert CREATE TABLE
                if 'CREATE TABLE' in line:
                    # Convert table name with backticks to temp_ prefix
                    line = re.sub(r'CREATE TABLE `([^`]+)`', r'CREATE TEMPORARY TABLE temp_\1', line)
                    # Remove MySQL engine and charset specifications
                    line = re.sub(r'\) ENGINE=\w+ DEFAULT CHARSET=\w+;', ');', line)
                
                # Convert data types
                line = re.sub(r'\bint\(\d+\)', 'INTEGER', line)
                line = re.sub(r'\btinyint\(\d+\)', 'SMALLINT', line)
                line = re.sub(r'\bsmallint\(\d+\)', 'SMALLINT', line)
                line = re.sub(r'\bmediumint\(\d+\)', 'INTEGER', line)
                line = re.sub(r'\bbigint\(\d+\)', 'BIGINT', line)
                line = re.sub(r'\bfloat\(\d+,\d+\)', 'REAL', line)
                line = re.sub(r'\bdouble\(\d+,\d+\)', 'DOUBLE PRECISION', line)
                line = re.sub(r'\bdecimal\(\d+,\d+\)', 'DECIMAL', line)
                line = re.sub(r'\bvarchar\((\d+)\)', r'VARCHAR(\1)', line)
                line = re.sub(r'\btext\b', 'TEXT', line)
                line = re.sub(r'\blongtext\b', 'TEXT', line)
                line = re.sub(r'\bmediumtext\b', 'TEXT', line)
                line = re.sub(r'\btinytext\b', 'TEXT', line)
                line = re.sub(r'\bdatetime\b', 'TIMESTAMP', line)
                line = re.sub(r'\btimestamp\b', 'TIMESTAMP', line)
                
                # Convert AUTO_INCREMENT
                line = re.sub(r'\bAUTO_INCREMENT\b', '', line)
                
                # Convert unsigned
                line = re.sub(r'\bUNSIGNED\b', '', line)
                
                # Remove backticks
                line = re.sub(r'`([^`]+)`', r'\1', line)
                
                # Convert INSERT statements
                if line.startswith('INSERT INTO '):
                    # Convert table names in INSERT statements
                    line = re.sub(r'INSERT INTO ([a-zA-Z_]+)', r'INSERT INTO temp_\1', line)
                
                # Convert LOCK/UNLOCK TABLES
                if 'LOCK TABLES' in line or 'UNLOCK TABLES' in line:
                    continue
                
                # Convert SET statements for character set
                if line.startswith('SET ') and 'character_set_client' in line:
                    continue
                
                if line != original_line:
                    converted_lines += 1
                
                outfile.write(line)
                
                # Progress indicator
                if line_count % 10000 == 0:
                    print(f"📊 Processed {line_count} lines, converted {converted_lines} lines")
    
    print(f"✅ Conversion complete: {line_count} lines processed, {converted_lines} lines converted")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 mysql_to_postgresql.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"❌ Input file not found: {input_file}")
        sys.exit(1)
    
    convert_mysql_to_postgresql(input_file, output_file)
