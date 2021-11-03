import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceSet;

import com.google.inject.Injector;

import at.bestsolution.jfr.JFRMetaStandaloneSetup;
import at.bestsolution.jfr.jFRMeta.Model;

public class RunIt {

	public static void main(String[] args) {
		Injector injector = new JFRMetaStandaloneSetup().createInjectorAndDoEMFRegistration();
		XtextResourceSet resourceSet = injector.getInstance(XtextResourceSet.class);
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE);
		Resource resource = resourceSet.getResource(
		    URI.createURI("file:/Users/tomschindl/git/jfr-doc/openjdk-16.jfr"), true);
		Model model = (Model) resource.getContents().get(0);
		model.getClasses().stream()
			.filter( c -> "jdk.jfr.Event".equals(c.getSuper()))
			.map( c -> c.getAnnotations()
					.stream().filter( a -> a.getType().getName().equals("Name")).map(a -> a.getValues().get(0).getValueString()).findFirst().orElse("UNKNOWN"))
			.forEach(System.err::println);
	}

}
