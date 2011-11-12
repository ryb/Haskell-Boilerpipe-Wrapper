package com.thoughtleadr.boilerpipe;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URL;
import java.util.Scanner;

import de.l3s.boilerpipe.extractors.ArticleExtractor;

class BoilerpipeCLI {
  public static void main(String[] args) throws Exception {
    
    String inputFilePath = args[0];
    String outputFilePath = args[1];
    
    String inputText = readFile(inputFilePath);
    
    String output = ArticleExtractor.INSTANCE.getText(inputText);
  
    writeFile(outputFilePath, output);
  }
  
  private static void writeFile( String file, String contents) throws IOException {
	  BufferedWriter writer = null;
      try{
    	  writer = new BufferedWriter( new FileWriter( file));
          writer.write( contents);
      }
      catch ( IOException e){}
      finally{
    	  try{
    		  if ( writer != null)
    			  writer.close( );
          }catch ( IOException e){}
      }
  }
  
  private static String readFile( String file ) throws IOException {
	    BufferedReader reader = new BufferedReader( new FileReader (file));
	    String line  = null;
	    StringBuilder stringBuilder = new StringBuilder();
	    String ls = System.getProperty("line.separator");
	    while( ( line = reader.readLine() ) != null ) {
	        stringBuilder.append( line );
	        stringBuilder.append( ls );
	    }
	    return stringBuilder.toString();
	 }
}