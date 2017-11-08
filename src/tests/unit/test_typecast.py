import nycdb
import datetime
from nycdb import typecast
from unittest.mock import patch
from types import SimpleNamespace
from decimal import Decimal

ARGS = SimpleNamespace(user='postgres', password='password', host='127.0.0.1', database='postgres', port='7777', root_dir='./data')

def test_integer():
    assert typecast.integer(10) == 10
    assert typecast.integer('10') == 10
    assert typecast.integer('  10  ') == 10
    assert typecast.integer('') is None

def test_integer_with_decimal():
    assert typecast.integer('1.0') == 1
    assert typecast.integer('25.923432') == 25

def test_char():
    assert typecast.char('test', 10) == 'test'
    assert typecast.char('test', 2) == 'te'
    assert typecast.char(' test', 2) == 'te'

def test_boolean():
    assert typecast.boolean('TRUE') is True
    assert typecast.boolean('no') is False
    assert typecast.boolean('am i true or false?') is None

def test_numeric():
    assert typecast.numeric('1.5') == Decimal('1.5')
    assert typecast.numeric('') is None

def test_date_mm_dd_yyyy():
    assert typecast.date('05/01/1925') == datetime.date(1925, 5, 1)

def test_date_bad_str():
    assert typecast.date('01/01/01') is None
    assert typecast.date('03/04/2015 12:00:00 AM XYZ') is None
    assert typecast.date('01/01/0000') is None

def test_date_mm_dd_yyyy_with_timestamp():
    assert typecast.date('03/04/2015 12:00:00 AM') == datetime.date(2015, 3, 4)
    
@patch('nycdb.dataset.Database')
def test_typecast_init(mock_database):
    t = typecast.Typecast(nycdb.Dataset('hpd_complaints', args=ARGS))
    assert isinstance(t.dataset, nycdb.Dataset)
    assert isinstance(t.fields, dict)
    assert t.fields['block'] == 'integer'
    assert isinstance(t.cast, dict)

@patch('nycdb.dataset.Database')
def test_typecast_generate_cast(mock_db):
    t = typecast.Typecast(nycdb.Dataset('hpd_complaints', args=ARGS))
    assert t.cast['boroughid']('123') == 123
    assert t.cast['borough'](' test  ') == 'test'
    assert t.cast['bbl']('0123456789X') == '0123456789'

@patch('nycdb.dataset.Database')
def test_cast_row(mock_db):
    t = typecast.Typecast(nycdb.Dataset('hpd_complaints', args=ARGS))
    row = { 'BoroughID': '123', 'Status': 'GOOD' }
    assert t.cast_row(row) == { 'BoroughID': 123, 'Status': 'GOOD' }