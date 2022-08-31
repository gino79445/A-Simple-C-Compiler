grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;
    int scope=0;
    int Scope=0;
    int whichscope=0;

    // Type information.
    public enum Type{
       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT;
    }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.

	};

    class Info {
           Type theType;  // type information.
       	   tVar theVar;
	   
	   Info() {
          	theType = Type.ERR;
		theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
    int[] scopeCount = new int[1000];
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();
    List<String> flabel = new ArrayList<String>();
    List<String> endlabel = new ArrayList<String>();
    


    /*
     * Output prologue.
     */
    void prologue()
    {
        TextCode.add("; === prologue ====");
        TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
        TextCode.add("define dso_local i32 @main()");
  	TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
        TextCode.add("\n; === epilogue ===");
	TextCode.add("ret i32 0");
       	TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    int strCount =0;
    String newStr()
    {
       strCount++;
       return (new String("str")) + Integer.toString(strCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program:(VOID|INT) MAIN '(' ')' '{'
  	{
           /* Output function prologue */
           prologue();
        }
 	 statements(RETURN (logic_arith_expression )? ';')? 
 	{
 	
           /* output function epilogue */	  
           epilogue();
        }
        
 	 
 	 
 	 
 	 '}'
	;

declaration:type a = Identifier
		{
	              if (TRACEON)
	                System.out.println("declarations: type Identifier : declarations");
	              
		      String str = $a.text+Integer.toString(scope);
		      //System.out.println(str);
		      //System.err.println(str);
           	      if (symtab.containsKey(str)) {
           	      	
		              // variable re-declared.
		              System.out.println("Type Error: " + $a.getLine() + ": Redeclared identifier.");
		              System.exit(0);
	              }
	              
	               
	           /* Add ID and its info into the symbol table. */
		       Info the_entry = new Info();
		       the_entry.theType = $type.attr_type;
		       the_entry.theVar.varIndex = varCount;
		       varCount ++;
		       symtab.put(str, the_entry);
	
           	// issue the instruction.
			   // Ex: \%a = alloca i32, align 4
	               if ($type.attr_type == Type.INT) { 
	                	TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
	               }
	        }
	        (',' b =Identifier
	        {
	              if (TRACEON)
	                System.out.println("declarations: type Identifier : declarations");
	
		      String str = $b.text+Integer.toString(scope);
		      //System.out.println(str);
           	      if (symtab.containsKey(str)) {
		              // variable re-declared.
		              System.out.println("Type Error: " + $b.getLine() + ": Redeclared identifier.");
		              System.exit(0);
	              }
	              
	                 
	           /* Add ID and its info into the symbol table. */
		       Info the_entry = new Info();
		       the_entry.theType = $type.attr_type;
		       the_entry.theVar.varIndex = varCount;
		       
		       varCount ++;
		       symtab.put(str, the_entry);
	
           	// issue the instruction.
			   // Ex: \%a = alloca i32, align 4
	               if ($type.attr_type == Type.INT) { 
	                	TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
	               }
	        }
	        
	        
	        
	        )* ';'
		
        	|type a = Identifier '=' logic_arith_expression ';'
        	{
	              if (TRACEON)
	                System.out.println("declarations: type Identifier : declarations");
	                
		      
		      String str = $a.text+Integer.toString(scope);
		      
		      
		      //System.err.println(str);
		      
           	      if (symtab.containsKey(str)) {
		              // variable re-declared.
		              System.out.println("Type Error: " + $a.getLine() + ": Redeclared identifier.");
		              System.exit(0);
	              }
	              
	           /* Add ID and its info into the symbol table. */
		       Info the_entry = new Info();
		       the_entry.theType = $type.attr_type;
		       the_entry.theVar.varIndex = varCount;
		       varCount ++;
		       symtab.put(str, the_entry);
			
	           // issue the instruction.
			   // Ex: \%a = alloca i32, align 4
	               if ($type.attr_type == Type.INT) { 
	                	TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
	               }
	               Info theRHS = $logic_arith_expression.theInfo;
		       Info theLHS = symtab.get(str); 
			   
	               if ((theLHS.theType == Type.INT) &&(theRHS.theType == Type.INT)) {		   
	                   // issue store insruction.
	                   // Ex: store i32 \%tx, i32* \%ty
	                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex+", align 4");
		       } else if ((theLHS.theType == Type.INT) &&(theRHS.theType == Type.CONST_INT)) {
	                   // issue store insruction.
	                   // Ex: store i32 value, i32* \%ty
	                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex+", align 4");				
		       }
	        }
		     
		        ;

type returns [Type attr_type]:INT{$attr_type=Type.INT; }
    ;

statements:statement statements
        |;

logic_arith_expression returns [Info theInfo]
@init {theInfo = new Info();}
		  : a =arith_expression { $theInfo=$a.theInfo; } 
                  ( GR_OP b =arith_expression
                     
                  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				
				varCount ++;
                       }else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sgt i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sgt i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                       
                     
                   
                 }
		  |LS_OP b =arith_expression
		  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp slt i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp slt i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
				
				
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                       
                     
                   
                 }
		  |EQ_OP  b =arith_expression
		  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp eq i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp eq i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                   }
		  |LE_OP b = arith_expression
		  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sle i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sle i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                   }
		  |GE_OP  b =arith_expression
		  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sge i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp sge i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                   }
		  |NE_OP  b =arith_expression
		  {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp ne i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = icmp ne i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.BOOL;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                   }
		  |AND  arith_expression
		  |OR   arith_expression

				  
		  )*	                  
		  ;
arith_expression returns [Info theInfo]
@init {theInfo = new Info();}
		: a = multExpr { $theInfo=$a.theInfo; }
                 ( ADD  b = multExpr
                 {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                 }
                 | SUB c = multExpr
                 {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($c.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($c.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($c.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ",\%t" + $c.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($c.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
                 }
                 )*	                  
		 ;	

multExpr returns [Info theInfo]
@init {theInfo = new Info();}
	  :  a = signExpr { $theInfo=$a.theInfo; }
          ( MUL_POINTER  b =signExpr
          {
                    // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ",\%t" + $b.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($b.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
           }
          | DIV  c =signExpr
          {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($c.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = sdiv  i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($c.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = sdiv  i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($c.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ",\%t" + $c.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($c.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
          }
          | MOD  d =signExpr 
          {
                       // We need to do type checking first.
                       // ...
					  
                       // code generation.					   
                       if (($a.theInfo.theType == Type.INT) &&($d.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $d.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
			        $theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&($d.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", " + $d.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($d.theInfo.theType == Type.INT)) {
                           	TextCode.add("\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ",\%t" + $d.theInfo.theVar.varIndex);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }else if (($a.theInfo.theType == Type.CONST_INT) &&($d.theInfo.theType == Type.CONST_INT)) {
                           	TextCode.add("\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", " + $d.theInfo.theVar.iValue);
					   
				// Update arith_expression's theInfo.
				$theInfo.theType = Type.INT;
				$theInfo.theVar.varIndex = varCount;
				varCount ++;
                       }
          }
             
	  )*
	  ;

signExpr returns [Info theInfo]
@init {theInfo = new Info();}
        : a=primaryExpr { $theInfo=$a.theInfo; } 
        | '-' primaryExpr
	;
		
		  
primaryExpr returns [Info theInfo] @init {theInfo = new Info();}
	  :DEC_NUM  
	  {
           	$theInfo.theType = Type.CONST_INT;
		$theInfo.theVar.iValue = Integer.parseInt($DEC_NUM.text);
	  }
          | Identifier 
          {
                // get type information from symtab.
                
                String str = $Identifier.text+Integer.toString(scope);
                Info v = symtab.get(str);
              	int i =scope;
		while(v==null){
				i = i -1;
				if (i<0){
					System.err.println("undefined var: "+$Identifier.text);
					System.exit(0);
				}
				str = $Identifier.text+Integer.toString(i);
				v = symtab.get(str);

				if(v!=null)
					break;
					
				
				
		}
                
                
                Type the_type = symtab.get(str).theType;
		$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get(str).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
                         // get a new temporary variable and
			 // load the variable into the temporary variable.
                         
			 // Ex: \%tx = load i32, i32* \%ty.
			 TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + vIndex+", align 4");
				         
			 // Now, Identifier's value is at the temporary variable \%t[varCount].
			 // Therefore, update it.
			 $theInfo.theVar.varIndex = varCount;
			 varCount ++;
                         break;
                case FLOAT:
                         break;
                case CHAR:
                         break;
			
                }
           }
           
	   | '(' a= logic_arith_expression ')' 
	   { $theInfo =a;} 

           ;

statement: Identifier '=' logic_arith_expression ';'
	  {
	  
	  	String str = $Identifier.text+Integer.toString(scope);
                Info v = symtab.get(str);
                //System.err.println(str);
              	int i =scope ;
		while(v==null){
				i = i -1;
				if (i<0){
					System.err.println("undefined var: "+$Identifier.text);
					System.exit(0);
				}
				str = $Identifier.text+Integer.toString(i);
				v = symtab.get(str);

				if(v!=null)
					break;
					
				
				
		}
                Info theRHS = $logic_arith_expression.theInfo;
		Info theLHS = symtab.get(str); 
		   
                if ((theLHS.theType == Type.INT) &&(theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex+", align 4");
		} else if ((theLHS.theType == Type.INT) &&(theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex+", align 4");				
		}
	   }
             
	  
         |IF '(' a=logic_arith_expression')'
         {	
         	
         	//System.err.println(scope);
         	String t = newLabel();
		String f = newLabel();
		String end = newLabel();
		flabel.add(f);
		endlabel.add(end);
         	if(a.theType == Type.BOOL){
         		
			TextCode.add("br i1  \%t" + $a.theInfo.theVar.varIndex +", label \%" + t+", label \%" + f);  
			TextCode.add(t+":");     
			 		
         	
         	}
         	
         	
         	
         } if_statements
         {	
         	String end = endlabel.get(endlabel.size() - 1);
         	TextCode.add("br label \%"+end);
         	
         	//System.err.println(scope + "ff");
         
         }
          ((ELSE) => ELSE 
          {	
          	
          	String f = flabel.get(flabel.size() - 1);
	        flabel.remove(flabel.size() - 1);        
         	TextCode.add(f+":");
          
          
          }
          else_statements{
          	
          	String end = endlabel.get(endlabel.size() - 1);
          	TextCode.add("br label \%"+end);
          	
          }
         |
         {
	         //scope = scope -1;
	         String f = flabel.get(flabel.size() - 1);
	         flabel.remove(flabel.size() - 1);        
         	 TextCode.add(f+":");
	         String end = endlabel.get(endlabel.size() - 1);
          	 TextCode.add("br label \%"+end);
          	 
	          
         
         }
         )
         {
 		String end = endlabel.get(endlabel.size() - 1);
	        endlabel.remove(endlabel.size() - 1);        
         	TextCode.add(end+":"); 
         	
         	
         	
         	
         
         }

	  
	 |logic_arith_expression';'
	 |SCANF '('STRING ',' '&'  Identifier(',' '&'Identifier)?   ')' ';'

	 |PRINTF '('STRING (',' a =logic_arith_expression(',' b =logic_arith_expression)?)?   ')' ';'
	 {
	 	String str = $STRING.text;
	 	str = str.substring(1, str.length()-1);
	 	int nCount=0;
	 	int len =str.length()+1;
	 	for( int i=0;i<str.length();i++){
		 	if(str.charAt(i)=='\\'){
		 		if(str.charAt(i+1)=='n'){
		 			str = str.substring(0, i+1)+ "0A" + str.substring(i+2,str.length() );
		 			i=i+2;
		 			nCount =nCount+1;
		 		}
	
	 		}
		}
		str =str+ "\\00";
		len = len - nCount;
	 		
	 	String string = newStr();
	 	//str = str.replace("\\n","\%n");
	 	TextCode.add(1,"@"+string+"= private unnamed_addr constant ["+Integer.toString(len)+" x i8] c\""+str+"\"");
		
		if($a.theInfo == null){
			//System.out.println(str);
			TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0))");
			 		
		}else if($b.theInfo == null ){
			if($a.theInfo.theType == Type.INT)
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+")");			   
              		if($a.theInfo.theType == Type.CONST_INT)
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+")");	
			
		}else{
			if($a.theInfo.theType == Type.INT && $b.theInfo.theType == Type.INT )
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+",i32 \%t"+$b.theInfo.theVar.varIndex+")");			   
              		if($a.theInfo.theType == Type.INT && $b.theInfo.theType == Type.CONST_INT )
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 \%t"+$a.theInfo.theVar.varIndex+",i32 "+$b.theInfo.theVar.iValue+")");		
			if($a.theInfo.theType == Type.CONST_INT && $b.theInfo.theType == Type.INT )
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+",i32 \%t"+$b.theInfo.theVar.varIndex+")");			   	   			
			if($a.theInfo.theType == Type.CONST_INT && $b.theInfo.theType == Type.CONST_INT )
				TextCode.add("call i32 (i8*, ...) @printf(i8* getelementptr inbounds (["+Integer.toString(len)+" x i8], ["+Integer.toString(len)+" x i8]* @"+string+", i64 0, i64 0),i32 "+$a.theInfo.theVar.iValue+",i32 "+$b.theInfo.theVar.iValue+")");			   	   			
		}
	 }
	
	 
	 |declaration
	 |';'
	 |COMMENT1 
	 |COMMENT2 
	 

	 
	 ;

	
	
	
if_statements : 
		{scope = scope +1;}(statement
                | '{' statements '}'){scope = scope -1;}
                
                                   
				  ;
else_statements : 
		
		(statement| '{' statements '}')
		
                
                
                  
				  ;


		   
/* description of the tokens */
MAIN 	: 'main';	
PRINTF 	: 'printf';
SCANF 	: 'scanf';
INT  : 'int';
CHAR : 'char';
VOID : 'void';
FLOAT: 'float';
WHILE : 'while';
ELSE : 'else';
FOR : 'for';
IF : 'if';
RETURN 	: 'return';


/*----------------------*/
/*  Compound Operators  */
/*----------------------*/
ADD : '+';
SUB : '-';
DIV : '/';
MUL_POINTER : '*';
MOD : '%';



GR_OP : '>' ;
LS_OP : '<' ;
EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
NE_OP : '!=';

PP_OP : '++';
MM_OP : '--'; 

AND : '&&';
OR : '||';

/*STRING*/


STRING	:  '"' ( ESC_SEQ|'""'| ~('"'|'\\') )* '"';
fragment ESC_SEQ	:   '\\' ('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\') ;
Char : '\'' ('\\\''|~'\'') '\'';


COMMA : ',';
ASSIGHNMENT : '=';
QUESTION_MARK : '?';
COLON :':';
SEMICOLON : ';';
LEFT_PARRENTHESE : '(';
RIGHT_PARRENTHESE : ')';
LEFT_BRACE : '{';
RIGHT_BRACE : '}';
LEFT_BRACKET : '[';
RIGHT_BRACKET : ']';

/*NUMBER*/
DEC_NUM : (DIGIT)+;
FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2;
fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;



//fragment FLOAT_NUM3: (DIGIT)+;


/*ID*/
Identifier : (LETTER)(LETTER | DIGIT)*;


/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}:.)* '*/';

/*NEW_LINE: '\n';*/

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';



WS  : (' '|'\r'|'\t'|'\n')+{skip();};
