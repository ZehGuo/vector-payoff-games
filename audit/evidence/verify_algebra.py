"""Phase 0 independent algebra/trajectory checks. Does not execute or modify MATLAB.
Run using Python with NumPy. Outputs finite-grid evidence, not theorem proofs.
Matrices below transcribed from the cited PDFs / legacy source, not prototype calls.
"""
from pathlib import Path
import json
import numpy as np

def rhs(x,A,b,alpha,rule='distance'):
    g=np.array([(A[k]@x+b[k])[k//2] for k in range(4)]).reshape(2,2)
    curv=np.array([A[k,k//2,k//2] for k in range(4)]).reshape(2,2)
    metric=np.abs(g/curv) if rule=='distance' else np.abs(alpha*g)
    return np.array([alpha[i,j]*g[i,j] if np.prod(g[i])>0 else 0 for i,j in enumerate(np.argmin(metric,axis=1))])
def values(X,A,b): return np.array([.5*np.sum((X@a)*X,axis=1)+X@bb for a,bb in zip(A,b)]).T

def integrate(A,b,alpha,x0,end,rule='distance',h=.001):
    X=np.empty((round(end/h)+1,2)); X[0]=x0
    for k in range(len(X)-1):
        x=X[k]; a=rhs(x,A,b,alpha,rule); c=rhs(x+h*a/2,A,b,alpha,rule); d=rhs(x+h*c/2,A,b,alpha,rule); e=rhs(x+h*d,A,b,alpha,rule)
        X[k+1]=x+h*(a+2*c+2*d+e)/6
    return X

def summarize(A,b,alpha,x0,end,rule='distance'):
    X=integrate(A,b,alpha,x0,end,rule); Xfine=integrate(A,b,alpha,x0,end,rule,h=.0005)
    V=values(X,A,b); vel=np.array([rhs(x,A,b,alpha,rule) for x in X])
    rates=np.array([np.sum((X@a+bb)*vel,axis=1) for a,bb in zip(A,b)]).T.reshape(-1,2,2)
    witnesses=[]
    for i in range(2):
        v=V[:,i*2:i*2+2]; witness=None
        for later in range(1,len(v)):
            hits=np.where(np.all(v[:later]>=v[later]-1e-7,axis=1)&np.any(v[:later]>v[later]+1e-7,axis=1))[0]
            if len(hits):
                earlier=int(hits[0]); witness={'t1':earlier*.001,'t2':later*.001,'earlier_minus_later':(v[earlier]-v[later]).tolist()};break
        witnesses.append(witness)
    return {'initial_rhs':rhs(np.array(x0),A,b,alpha,rule).tolist(),'terminal':X[-1].tolist(),'terminal_step_halving_error':float(np.max(np.abs(X[-1]-Xfine[-1]))),'minimum_rates':rates.min(axis=0).tolist(),'minimum_per_agent_best_rate':rates.max(axis=2).min(axis=0).tolist(),'trap_witnesses':witnesses},X

out={'method':'Independent NumPy algebra; fixed-step RK4 h=0.001 vs 0.0005; sampled rates/traps tolerance 1e-7; not MATLAB execution or continuous-time proof.'}
A=np.array([[[-2,1],[1,-3]],[[-4,-4],[-4,-12]],[[-7,1],[1,-2]],[[-3,-1],[-1,-2]]],float)
for name,b,x0 in [('ch4_paper_strong',[[0,-1.25],[-30,1],[55.5,-5],[24.5,0]],[0,0]),('ch4_legacy_strong',[[15,-1.25],[30,-1],[55.5,-5],[24.5,0]],[0,0]),('ch4_weak',[[5,12],[30,0],[-20,0],[20,0]],[0,3])]:
 out[name],_=summarize(A,np.array(b),np.array([[1,.5],[1,1]]),x0,5)
An=np.array([[[-4,-1],[-1,-3]],[[-2,-1],[-1,-10]],[[-2,1],[1,-2]],[[-5,1],[1,-1]]],float)
out['ch4_nonweak_assumed_normalized_sensitivity'],_=summarize(An,np.array([[10,22],[10,78],[8,0],[5,0]]),np.array([[1,2],[1,2]]),[7,13],5)
At=np.array([[[-2,1],[1,-3]],[[-2,-1],[-1,-10]],[[-4,1],[1,-4]],[[-5,-1],[-1,-2]]],float)
bt=np.array([[5,-5],[20,124],[90,0],[72,0]])
for name,alpha,rule in [('trap_legacy',[[1,1.2],[1,2]],'scaled'),('trap_caption',[[1.2,1.2],[1.25,1]],'distance')]:
 out[name],X=summarize(At,bt,np.array(alpha),[18.5,-8.71],4,rule)
 out[name]['agent2_change_at_2_75']=(values(X[[2750]],At,bt)-values(X[[0]],At,bt))[0,2:].tolist()
UA=np.einsum('k,kij->ij',[1,3,1,3],At); JA=At.sum(axis=0)
out['budget_sigma_hessian_roots']=sorted(np.linalg.eigvals(np.linalg.solve(UA,JA)).tolist())
Ai=np.array([[[-4,1],[1,-10]],[[-4,-1],[-1,-3]],[[-16,8],[8,-16]],[[-5,-1],[-1,-2]]],float)
for name,b,eta,omega,zeta,sigma,x0,end in [('incentive_thesis',[[5,-440],[30,-20],[360,0],[58.5,0]],[.7,4,1,2],[0,0],[.3,.7],.05,[16,-15],3),('incentive_supplement',[[5,730],[30,-295],[360,0],[180,0]],[.5,2.5,.5,2],[1,4],[.5,.5],3,[21,-35],2)]:
 b=np.array(b,float); U=np.einsum('k,kij->ij',eta,Ai); ub=np.array(eta)@b; target=-np.linalg.solve(U,ub)
 modified=Ai.copy(); mb=b.copy()
 for i in range(2):modified[i*2]=zeta[i]*sigma*U-omega[i]*Ai[i*2+1];mb[i*2]=zeta[i]*sigma*ub-omega[i]*b[i*2+1]
 alpha=np.array([[1,modified[0,0,0]/modified[1,0,0]],[1,modified[2,1,1]/modified[3,1,1]]])
 result,X=summarize(modified,mb,alpha,x0,end)
 delta=values(X,Ai,b)-values(np.array([x0]),Ai,b)
 plotted=sigma*(delta@eta)-delta[:,0]-delta[:,2];true=plotted-delta[:,1]*omega[0]-delta[:,3]*omega[1]
 result.update(target=target.tolist(),det_social_hessian=float(np.linalg.det(U)),legacy_sensitivity=alpha.tolist(),true_budget_minmax=[float(true.min()),float(true.max())],plotted_budget_minmax=[float(plotted.min()),float(plotted.max())],max_budget_plot_error=float(np.max(np.abs(plotted-true))))
 out[name]=result
As=np.array([[[-2,-1],[-1,-3]],[[-4,-4],[-4,-12]],[[-7,1],[1,-2]],[[-3,1],[1,-1]]],float)
bs=np.array([[8,0],[30,0],[4,0],[12,0]])
x0=np.array([6.5,-10]); g=np.array([(As[k]@x0+bs[k])[k//2]/As[k,k//2,k//2] for k in range(4)]).reshape(2,2)
out['extension_eta0']=g[np.arange(2),np.argmin(np.abs(g),axis=1)].tolist()
T=np.array([[6.2058,-1.0547,-2.5757,.1138],[-1.0547,4.3862,3.9895,.6236],[-2.5757,3.9895,6.2058,-2.8365],[.1138,.6236,-2.8365,4.3862]])
UW=np.array([[0,1],[1,0]]); cert=[]
for j in range(2):
 for k in range(2):
  R=np.array([As[j,0]/As[j,0,0],As[2+k,1]/As[2+k,1,1]]); D=np.diag([[-1,-1][j],[-10,-1][k]]); C=R@D
  E=np.diag([2*j-1,2*k-1]);F=np.vstack([E,np.eye(2)]);P=F.T@T@F
  cert.append({'branch':[j+1,k+1],'transformed_matrix':C.tolist(),'max_decay_eigenvalue':float(np.linalg.eigvalsh(C.T@P+P@C+E.T@UW@E).max()),'min_positive_eigenvalue':float(np.linalg.eigvalsh(P-E.T@UW@E).min())})
out['extension_certificate']=cert
Path(__file__).with_name('algebra_checks.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
