MIL_3_Tfile_Hdr_ 145A 140A modeler 9 4BFC7E63 4C0B02F4 39 china-0f9728557 Administrator 0 0 none none 0 0 none 5D3260EA 233B 0 0 0 0 0 0 1e80 8                                                                                                                                                                                                                                                                                                                                                                                 ��g�      @      �  �  �  !  !  !  !#  !/  !3  !7  �      Start Grade Timer   �������   ����               ����              ����              ����           �Z             SIFS   �������   ����               ����              ����              ����           �Z             durDATA   �������   ����               ����              ����              ����           �Z             durCTS   �������   ����               ����              ����              ����           �Z                 	   begsim intrpt         
   ����   
   doc file            	nd_module      endsim intrpt         
   ����   
   failure intrpts            disabled      intrpt interval         ԲI�%��}����      priority              ����      recovery intrpts            disabled      subqueue                     count    ���   
   ����   
      list   	���   
          
      super priority             ����             Objid	\process_id;       Objid	\node_id;       int	\node_address;       double	\start_grade_timer;       int	\grade;       Boolean	\RTS_flag;       
int	\dest;       double	\SIFS;       Evhandle	\wait_DATA_event;       double	\durDATA;       double	\durCTS;          Packet* pk_TV;   //int pk_type;      //Define packet type   #define grade_pk  1   #define rts_pk    2   #define cts_pk    3   #define ack_pk    4   #define data_pk   5       //Define stream in-out NO.   #define SRC_STRM 		1   #define RCV_STRM 		0   #define SEND_STRM 		0   #define DISCARD_STRM 	1        #define START_GRADE_CODE				1000   #define SEND_CTS_CODE					2000   #define NO_DATA_CODE					3000   #define SEND_ACK_CODE					4000       i#define START_GRADE					((op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code() == START_GRADE_CODE))   c#define SEND_CTS					((op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code() == SEND_CTS_CODE))   b#define NO_DATA						((op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code() == NO_DATA_CODE))   c#define SEND_ACK					((op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code() == SEND_ACK_CODE))       `#define FROM_LOWER					((op_intrpt_type() == OPC_INTRPT_STRM) && (op_intrpt_strm() == RCV_STRM))   B#define END	        		    	(op_intrpt_type() == OPC_INTRPT_ENDSIM)       //function prototype   static void rcv_pk_proc(void);   :       //receive data from lower layer   static void   rcv_pk_proc(void)   {   //var   	int pk_type, grade_in_pk;   	int hop_num_TV;   	Packet *pk;   //in   	FIN(rcv_pk_proc(void));   //body   	pk = op_pk_get(RCV_STRM);   #	op_pk_nfd_get(pk,"Type",&pk_type);   (	op_pk_nfd_get(pk,"Grade",&grade_in_pk);   	switch(pk_type)   	{   		case rts_pk:   		{   			//reply_cts(pk);   I			if(grade_in_pk == grade+1 && !RTS_flag)//the first time to receive RTS   			{   				RTS_flag = OPC_TRUE;   "				op_pk_nfd_get(pk,"Src",&dest);   >				op_intrpt_schedule_self(op_sim_time()+SIFS,SEND_CTS_CODE);   6				printf("Have received RTS. Wait to reply CTS.\n");   			}   			op_pk_destroy(pk);   				break;   		}   		case data_pk:   		{   #			if(op_ev_valid(wait_DATA_event))   			{   "				op_ev_cancel(wait_DATA_event);   				//RTS_flag = OPC_FALSE;   +				op_pk_nfd_get(pk,"Previous Hop",&dest);   				   -				op_pk_nfd_get(pk,"Hop Num", &hop_num_TV);   				hop_num_TV++;   +				op_pk_nfd_set(pk,"Hop Num",hop_num_TV);   				    				op_pk_send(pk,DISCARD_STRM);   				   >				op_intrpt_schedule_self(op_sim_time()+SIFS,SEND_ACK_CODE);   7				printf("Have received DATA. Wait to reply ACK.\n");   			}   				break;   		}   
		default:   		{   			op_pk_destroy(pk);   ?			printf("The received pk is not RTS or DATA, destroy it.\n");   		}   	}   //out   	FOUT;   }                                          �            
   init   
       
      // Obtain related ID   process_id = op_id_self();   %node_id = op_topo_parent(process_id);       RTS_flag = OPC_FALSE;       Iop_ima_obj_attr_get(process_id, "Start Grade Timer", &start_grade_timer);   /op_ima_obj_attr_get(process_id, "SIFS",&SIFS);	   4op_ima_obj_attr_get(process_id, "durDATA",&durDATA);   2op_ima_obj_attr_get(process_id, "durCTS",&durCTS);       7op_ima_obj_attr_get(node_id, "user id", &node_address);       Lop_intrpt_schedule_self(op_sim_time() + start_grade_timer,START_GRADE_CODE);   
                     
   ����   
          pr_state        �            
   idle   
                                       ����             pr_state        J   Z          
   start grade   
       
   
   &//Sink will execute the following code   
grade = 0;   //sink_id = node_address;       )pk_TV = op_pk_create_fmt("MAC_GRADE_PK");   'op_pk_nfd_set(pk_TV, "Type", grade_pk);   +//op_pk_nfd_set(pk_TV, "Sink ID", sink_id);   'op_pk_nfd_set(pk_TV, "Grade", grade+1);       op_pk_send(pk_TV, SEND_STRM);   
                     
   ����   
          pr_state        :   Z          
   RCV proc   
       
      //receive data from lower layer   rcv_pk_proc();   
                     
   ����   
          pr_state        J  �          
   send CTS   
       
      //send CTS	   'pk_TV = op_pk_create_fmt("MAC_CTS_PK");   $op_pk_nfd_set(pk_TV,"Type", cts_pk);   (op_pk_nfd_set(pk_TV,"Src",node_address);   !op_pk_nfd_set(pk_TV,"Dest",dest);   #op_pk_nfd_set(pk_TV,"Grade",grade);   		   op_pk_send(pk_TV, SEND_STRM);       //wait DATA   ]wait_DATA_event = op_intrpt_schedule_self(op_sim_time() + durCTS+SIFS+durDATA, NO_DATA_CODE);   7printf("Have replied CTS, waiting to receive DATA.\n");   
                     
   ����   
          pr_state        :  �          
   no DATA   
       
      RTS_flag = OPC_FALSE;   
                     
   ����   
          pr_state        �            
   send ACK   
       
   
   
//send ACK   'pk_TV = op_pk_create_fmt("MAC_ACK_PK");   #op_pk_nfd_set(pk_TV,"Type",ack_pk);   (op_pk_nfd_set(pk_TV,"Src",node_address);   !op_pk_nfd_set(pk_TV,"Dest",dest);   #op_pk_nfd_set(pk_TV,"Grade",grade);       op_pk_send(pk_TV,SEND_STRM);   printf("Have replied ACK.\n");   RTS_flag = OPC_FALSE;   
                     
   ����   
          pr_state                       O        �    �            
   tr_0   
       ����          ����          
    ����   
          ����                       pr_transition              �   �     �  	  M   g          
   tr_1   
       
   START_GRADE   
       ����          
    ����   
          ����                       pr_transition              5   �     Y   a  �   �          
   tr_2   
       
����   
       ����          
    ����   
          ����                       pr_transition              �   �     �    .   X          
   tr_3   
       
   
FROM_LOWER   
       ����          
    ����   
          ����                       pr_transition                 �     9   \  �   �          
   tr_4   
       ����          ����          
    ����   
          ����                       pr_transition              |  b     �    E  �          
   tr_5   
       
   SEND_CTS   
       ����          
    ����   
          ����                       pr_transition              �  e     Y  �  �            
   tr_6   
       ����          ����          
    ����   
          ����                       pr_transition                l     �    M  �          
   tr_7   
       
   NO_DATA   
       ����          
    ����   
          ����                       pr_transition              �  j     /  �  �  &          
   tr_8   
       ����          ����          
    ����   
          ����                       pr_transition      
        =       �    �            
   tr_10   
       
   SEND_ACK   
       ����          
    ����   
          ����                       pr_transition              :       �    �            
   tr_11   
       ����          ����          
    ����   
          ����                       pr_transition              �   �     �    �   �  �    �  	          
   tr_13   
       
   default   
       ����          
    ����   
       
    ����   
                    pr_transition                                             